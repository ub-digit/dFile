require 'free_disk_space'
require 'nokogiri'

class QueueManager
  MAXIMUM_PROCESSES = 1 # Sets maximum allowed processes at the same time
  MAXIMUM_FORKS = 5 # Sets maximum of concurrent forks allowed to start
  MINIMUM_FREE_DISK_SPACE = 50 # Sets the minimum of free disk space before starting a writing operation

  def run

    redis_first = RedisInterface.new
    forks_count = redis_first.get("dFile:forks") || "0"
    if forks_count.to_i > MAXIMUM_FORKS
      Rails.logger.info "FORKS: Maximum number of allowed forks reached #{MAXIMUM_FORKS}, aborting!"
      return
    end

    Rails.logger.info "Running queue manager"
    # Fork process to allow calling method to finish
    pid = fork
    if pid.nil?

      Rails.logger.info "Created a new instance of queue manager (fork)"

      redis.incr("dFile:forks")

      run = true
      while run do
        # Check if there are any running processes
        running_keys = redis.keys("dFile:processes:*:state:running")
        if running_keys && running_keys.count >= MAXIMUM_PROCESSES
          Rails.logger.info "There are already processes running: #{running_keys.to_json} , aborting!"
          exit_fork
        end

        # Check if there are any queued processes
        queued_keys = redis.keys("dFile:processes:*:state:queued")
        if queued_keys.empty?
          Rails.logger.info "There are no queued processes, aborting!"
          exit_fork
        end

        # Parse queued processes
        queued_processes = []
        queued_keys.each do |key|
          process_id = redis.get(key)

          params = redis.get("dFile:processes:#{process_id}:params")
          if params.nil?
            sleep 3
            params = RedisInterface.new.get("dFile:processes:#{process_id}:params")
          end
          if params.nil?
            Rails.logger.info "No parameters are set for #{process_id}, aborting!"
            exit_fork
          end

          process_object = {
            id: process_id,
            process: redis.get("dFile:processes:#{process_id}:process"),
            params: JSON.parse(params),
              priority: redis.get("dFile:processes:#{process_id}:priority")
          }
          queued_processes << process_object
        end

        # Sort based on priority
        queued_processes.sort! { |a,b| a[:priority] <=> b[:priority] }

        # Choose the first process to run
        first_process = queued_processes.first

        # Create process object
        process = ProcessObject.new(id: first_process[:id], name: first_process[:process], params: first_process[:params])

        Rails.logger.info "Selected process for execution: #{process.to_json}"

        # Make sure process is still queued
        if process.redis.get("state:queued").nil?
          Rails.logger.info "Process is no longer in queued state, aborting!"
          exit_fork
        end

        redis.transaction do
          # Remove queued key and create running key
          process.redis.set("state:running", process.id)
          process.redis.del("state:queued")

        end #End redis transaction

        Rails.logger.info "Starting process #{process.name} for id: #{process.id}"

        # Run the process
        case process.name
        when "CHECKSUM"
          checksum(process: process, source_file: process.params['source_file'])
        when "MOVE_FOLDER"
          copy_folder(delete_source: true, process: process, source_dir: process.params['source_dir'], dest_dir: process.params['dest_dir'])
        when "COPY_FOLDER"
          copy_folder(delete_source: false, process: process, source_dir: process.params['source_dir'], dest_dir: process.params['dest_dir'])
        when "OCR_FOLDER"
          ocr_folder(process: process, source_dir: process.params['source_dir'], dest_dir: process.params['dest_dir'], formats: process.params['dest_dir'], languages: process.params['languages'], documentSeparationMethod: process.params['documentSeparationMethod'], deskew: process.params['deskew'])

        end


        process.set_as_done
      end
    else
      # Parent process
      Process.detach(pid)
      puts "Detached process, returning"
      return
    end
  end

  def exit_fork(state = :aborted)
    Rails.logger.info "FORK: Exiting process #{Process.pid} (#{state})"
    redis.decr("dFile:forks")
    Process.exit!
  end

  def redis
    @redis ||= RedisInterface.new
  end

  # Calcluates a checksum for given source_file and sets result key
  def checksum(process:, source_file:)
    source_file = Item.new(Path.new(source_file))
    Rails.logger.info "CHECKSUM: Source file: #{source_file.path.to_s}"

    # If file does not exist, create error key and message
    if !source_file.path.exist?
      process.error_msg("Source file #{source_file.path.to_s} does not exist!")
      return
    end

    begin
      checksum = FileManager.checksum(source_file.path)
      process.redis.set('value', checksum)
    rescue StandardError => e
      process.redis.set('value', "error")
      process.redis.set('error', e.inspect)
    end
  end

  # Moves given source_folder to dest_folder
  def copy_folder(process:, delete_source: false, source_dir:, dest_dir:)
    start_time = Time.now
    source_dir = Item.new(Path.new(source_dir))
    dest_dir = Item.new(Path.new(dest_dir))

    Rails.logger.info "MOVE_FOLDER #{source_dir.path.to_s} to #{dest_dir.path.to_s}"

    # Make sure source dir exist
    if !source_dir.exist? || !source_dir.dir?
      process.error_msg("Source directory #{source_dir.path.to_s} does not exist")
      return
    end

    # Make sure dest_dir doesn't exist
    if dest_dir.exist?
      process.error_msg("Destination directory #{dest_dir.path.to_s} already exists")
      return
    end

    # Make sure dest dir has enough free space
    free_disk_space = FreeDiskSpace.gigabytes(dest_dir.path.parent.to_s)
    if free_disk_space < MINIMUM_FREE_DISK_SPACE
      process.error_msg("Destination directory does not have enough disk space: #{free_disk_space.to_i}GB, required: #{MINIMUM_FREE_DISK_SPACE}GB")
      return
    end

    begin
      # Copy folder to dest_dir
      FileManager.create_structure(dest_dir.path.to_s)
      number_of_files = source_dir.path.all_files.count
      folder_size = source_dir.path.total_size
      source_dir.path.all_files.each_with_index do |source_file, index|
        process.redis.set('progress', "Copying file #{index+1}/#{number_of_files}, #{source_file.basename}, Total size: #{folder_size}")
        dest_file = Pathname.new("#{dest_dir.path.to_s}/#{source_file.basename}")
        FileManager.copy(source_file, dest_file)
      end

      end_time = Time.now
      total_time = end_time - start_time

      if delete_source
        # Remove folder from source_dir
        redis.set('progress', value: "Deleting source folder after copy #{source_dir.path.to_s}, Total size: #{folder_size}")
        FileManager.delete_directory(source_dir.path)
        process.redis.set('progress', "Moved #{source_dir} to #{dest_dir} in #{total_time.to_i}s")
      else
        process.redis.set('progress', "Copied #{source_dir} to #{dest_dir} in #{total_time.to_i}s")
      end


      process.redis.set('value', dest_dir.path.to_s)
    rescue StandardError => e
      process.redis.set('value', 'error')
      process.redis.set('error', e.inspect)
    end
  end

  # Creates ticket for input folder files and copies files to ocr folder
  def ocr_folder(process:, source_dir:, dest_dir:, formats: nil, languages: nil, documentSeparationMethod: nil, deskew: nil)
    Rails.logger.info("OCR for folder #{source_dir}")

    ocr_path = Path.new(Rails.application.config.ocr_path)
    source_dir = Item.new(Path.new(source_dir))
    dest_dir = Item.new(Path.new(dest_dir))
    formats = formats || [{type: 'PDF'}]
    languages = languages || ["English", "Swedish"]
    documentSeparationMethod = documentSeparationMethod || "OneFilePerImage"
    deskew = deskew || "True"
    
    images = source_dir.path.files_as_array
    # Create ticket
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.XmlTicket(:priority => "high") {
        images.each do |image|
          xml.InputFile(:Name => image )
        end
        xml.ImageProcessingParams(:Deskew => deskew, :RemoveTexture => "false", :SplitDualPages => "false", :ConvertToBWFormat => "false", :RotationType => "NoRotation")
        xml.RecognitionParams(:RecognitionQuality => "Thorough", :LookForBarcodes => "false", :VerificationMode => "NoVerification", :RecognitionMode => "FullPage") {
          xml.TextType "Normal"
          languages.each do |language|
            xml.Language language
          end
        }
        xml.ExportParams(:DocumentSeparationMethod => documentSeparationMethod, :DeleteBlankPages => "false", :XMLResultPublishingMethod => "XMLResultToFolder") {
          formats.each do |format|
            if format['type'] == "PDF"
              # Set up default values
              pictureFormat = format['pictureFormat'] || "JpegColor"
              quality = format['quality'] || "60"
              pictureResolution = format['pictureResolution'] || "200"
              xml.ExportFormat(:OutputFileFormat => "PDF", :KeepLastModifiedDate => "false", :OutputFlowType => "SharedFolder", :ExportMode => "ImageOnText", :WriteTaggedPdf => "true", :PictureFormat => pictureFormat, :Quality => quality, :PictureResolution => pictureResolution, :UseExplicitDocumentInfo => "false", :UseOriginalPaperSize => "true", :KeepOriginalHeadersFooters => "false", :WriteAnnotations => "false", :PdfVersion => "Auto", :UseImprovedConversion => "false") {
                xml.OutPutLocation dest_dir.path.to_s + '/' + process.id
                xml.NamingRule "<FileName>.<Ext>"
              }
            end
          end
        }
      }
    end
    puts builder.to_xml

    # Send ticket to OCR-path
    ticket_file = Item.new(Path.new(ocr_path.to_s + "/#{process_id}.xml"))
    ticket_file.create(builder.to_xml)
    Rails.logger.info("Ticket created #{ticket_file.path.to_s}")

    # Copy files to OCR-path
    copy_folder(process: process, delete_source: false, source_dir: source_dir.path.to_s, dest_dir: ocr_path.to_s + "/#{process_id}")
    Rails.logger.info("Files copied to OCR-path")
  end

  class ProcessObject
    attr_reader :id, :name, :params
    def initialize(id:,name:, params:)
      @id = id
      @name = name
      @params = params
    end

    def to_json
      {id: id, name: name, params: params}.to_json
    end

    def set_as_done

      # Set state to done
      redis.del("state:running")
      redis.set("state:done", @id)
      redis.set("state", "DONE")

      Rails.logger.info "########### Process done! ############"
    end

    def error_msg(msg)
      Rails.logger.error "#{name}: #{msg}"
      redis.set("error", msg)
      redis.set("value", 'error')
    end

    def redis
      @redis ||= RedisInterface.new(prefix: "dFile:processes:#{id}:")
    end
  end
end
