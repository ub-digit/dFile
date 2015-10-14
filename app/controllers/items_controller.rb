class ItemsController < ApplicationController

	# Calculate checksum of file
	def checksum 
		source_file = Item.new(Path.new(params[:source_file]))
		response = {}
		response[:source_file] = source_file

		if !source_file.path.exist?
			response[:msg] = "Fail"
			render json: response
			return
		end

    # Ask redis for id
    redis = RedisInterface.new
    id = redis.incr('dFile:id') 

    # Create work order item in redis for dFile
    redis.transaction do
      redis.set("dFile:processes:#{id}:state:queued", id)
      redis.set("dFile:processes:#{id}:state", "QUEUED")
      redis.set("dFile:processes:#{id}:process", "CHECKSUM")
      redis.set("dFile:processes:#{id}:params", params.to_json)
      redis.set("dFile:processes:#{id}:priority", "1")
    end

    # Start QueueManager
    QueueManager.new.run

		if id
			response[:msg] = "Success"
			response[:id] = id
      render json: response, status: 200
		else
			response[:msg] = "Fail"
      render json: response, status: 400
		end

	end	

  def create_process(process:)
    # Ask redis for id
    redis = RedisInterface.new
    id = redis.incr('dFile:id')


    # Create process item 
    redis.transaction do
      redis.set("dFile:processes:#{id}:state:queued", id)
      redis.set("dFile:processes:#{id}:state", "QUEUED")
      redis.set("dFile:processes:#{id}:process", process)
      redis.set("dFile:processes:#{id}:params", params.to_json)
      redis.set("dFile:processes:#{id}:priority", "1")
    end

    
    QueueManager.new.run

    response = {}
    if id
      response[:msg] = "Success"
      response[:id] = id
      render json: response, status: 200
    else
      response[:msg] = "Fail"
      render json: response, status: 400
    end
    
  end

  # Moves a source_dir to dest_dir file by file
  def move_folder_ind
    create_process(process: "MOVE_FOLDER")
  end

  # Copies a source_dir to dest_dir file by file
  def copy_folder_ind
    create_process(process: "COPY_FOLDER")
  end

  # Returns a file, or information about a file
  def download_file
    source_file = Item.new(Path.new(params[:source_file]))
    response = {}
    response[:source_file] = source_file

    if !source_file.path.exist?
      response[:msg] = "Fail"
      render json: response, status: 404
      return
    end

    respond_to do |format|
      format.json { render json: response }
      format.file { send_file source_file.path.to_path }
    end
    
  end

  #Copies a file as given destination file
  def create_file
    dest_file = Item.new(Path.new(params[:dest_file]))
    content = params[:content]
    response = {}
    response[:dest_file] = dest_file
    permission = params[:force_permission]
    if dest_file.create(content, permission)
      response[:msg] = "Success"
      render json: response, status: 200
    else
      response[:msg] = "Fail"
      render json: response, status: 422
    end
  end

	#Copies a file as given destination file
	def copy_file
		source_file = Item.new(Path.new(params[:source_file]))
		dest_file = Item.new(Path.new(params[:dest_file]))
		response = {}
		response[:source_file] = source_file
		response[:dest_file] = dest_file
		if source_file.copy_to(dest_file)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	# Copies files of a given type from a source directory to destination
	def copy_files
		source_dir = Item.new(Path.new(params[:source]))
		dest_dir = Item.new(Path.new(params[:dest]))
		type  = params[:type]
		response = {}
		response[:source_dir] = source_dir
		response[:dest_dir] = dest_dir
		if source_dir.copy_files_to(dest_dir, type)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	# Returns a list of all files in directory
	def list_files
		source_dir = Path.new(params[:source_dir])
    if params.has_key?(:show_catalogues)
      show_catalogues = params[:show_catalogues]
    else
      show_catalogues = false
    end
		render json: source_dir.files(params[:ext], show_catalogues)
	end

	# Combines pdf files within a source directory and stores them as a single file
	def combine_pdf_files
		source_dir = Item.new(Path.new(params[:source]))
		dest_file = Item.new(Path.new(params[:dest]+".pdf"))

		response = {}
		if !source_dir.path.exist?
			response[:msg] = "Fail"
			render json: response
			return
		end

		dest_file.path.create_structure
		pdf_files = source_dir.path.files_as_array('pdf')

		response[:source_dir] = source_dir
		response[:dest_file] = dest_file
		response[:files_combined_count] = pdf_files.size

		if FileManager.combine_pdf_files(pdf_files,dest_file.path)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	#Moves files of a given type from a source directory to destination
	def move_file
		source_file = Item.new(Path.new(params[:source_file]))
		dest_file = Item.new(Path.new(params[:dest_file]))

		response = {}
		response[:source_file] = source_file
		response[:dest_file] = dest_file
		if source_file.move_to(dest_file)
			response[:msg] = "Success"
      render json: response, status: 200
		else
			response[:msg] = "Fail"
      render json: response, status: 402
		end
	end

	#Moves files of a given type from a source directory to destination
	def move_files
		source_dir = Item.new(Path.new(params[:source]))
		dest_dir = Item.new(Path.new(params[:dest]))
		type  = params[:type]
		response = {}
		response[:source_dir] = source_dir
		response[:dest_dir] = dest_dir
		if source_dir.move_files_to(dest_dir, type)
			response[:msg] = "Success"
      render json: response, status: 200
		else
			response[:msg] = "Fail"
      render json: response, status: 402
		end
	end

  #Moves files of a given type from a source directory to destination
  def move_folder
    source_dir = Item.new(Path.new(params[:source_dir]))
    dest_dir = Item.new(Path.new(params[:dest_dir]))

    response = {}
    response[:source_dir] = source_dir
    response[:dest_dir] = dest_dir
    if source_dir.move_to(dest_dir)
      response[:msg] = "Success"
      render json: response, status: 200
    else
      response[:msg] = "Fail"
      render json: response, status: 402
    end
  end

	# Returns file count of specific file type in given directory
	def file_count
		source_dir = Item.new(Path.new(params[:source]))
		type = params[:type]

		response = {}
		response[:source_dir] = source_dir
		file_count = source_dir.path.file_count(type)
		
		if file_count
			response[:msg] = "Success"
			response[:file_count] = file_count
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

	# Returns an image file from source directory and file type
	def get_image
		source_file = Item.new(Path.new(params[:source]+"."+params[:type]))
		begin
			send_file source_file.path, :filename => source_file.path.basename.to_s, :type => "image/#{params[:type]}"
		rescue 
			not_found
		end
	end

	# Copies images of specified type from source directory to destination, converted with given parameters
	def copy_and_convert_images
		source_dir = Item.new(Path.new(params[:source]))
		dest_dir = Item.new(Path.new(params[:dest]))
		source_type = params[:source_type]
		dest_type = params[:dest_type]
		quality = params[:quality]
		size = params[:size]

		response = {}
		response[:source_dir] = source_dir
		response[:dest_dir] = dest_dir
		if source_dir.copy_and_convert_files_to(dest_dir, source_type, dest_type, quality, size)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response

	end

	# Copies images of specified type from source directory to destination, converted with given parameters
	def copy_and_convert_image
		source_file = Item.new(Path.new(params[:source] + "." + params[:source_type]))
		destination_type = params[:dest_type] || params[:source_type]
		dest_file = Item.new(Path.new(params[:dest] + "." + destination_type))
		quality = params[:quality]
		size = params[:size]

		response = {}
		response[:source_file] = source_file
		response[:dest_file] = dest_file
		if source_file.copy_and_convert_to(dest_file, quality, size)
			response[:msg] = "Success"
		else
			response[:msg] = "Fail"
		end
		render json: response
	end

  # Moves source_dir to archive folder with suffix if folder exists
  def move_to_trash
    source_dir = Item.new(Path.new(params[:source_dir]))
    dest_dir_root = Item.new(Path.new("TRASH:" + source_dir.path.input_path))

    dest_dir_string = dest_dir_root.path.to_s
    dir_found = false
    i = 1
    while(!dir_found)
      dest_dir = Item.new(Path.new(dest_dir_string))
      if dest_dir.exist?
        dest_dir_string = dest_dir_root.path.to_s + "_#{i}"
        i += 1
      else
        dir_found = true
      end
    end

    response = {}
    if !source_dir.exist?
      response[:msg] = "No folder at location, nothing to do"
      render json: response, status: 200
    elsif source_dir.move_to(dest_dir)
      response[:msg] = "Success"
      render json: response, status: 200
    else
      response[:msg] = "Fail"
      render json: response, status: 422
    end
  end

  # Returns a thumbnail file for a specified source with given size and source type
  def thumbnail
    source_dir = Item.new(Path.new(params[:source_dir]))
    
    response = {}
    
    # Check if source package folder exists
    if !source_dir.exist?
      response[:msg] = "No folder at location, nothing to do"
      render json: response, status: 404
      return
    end

    # Check if original file exists
    original_file = Item.new(Path.new(source_dir.path.to_s + "/#{params[:source]}/#{params[:image]}.tif"))
    
    if !original_file.exist?
      response[:msg] = "No original file at location #{original_file.path.to_s}, nothing to do"
      render json: response, status: 404
      return
    end

    # Check if thumnail file exists
    thumbnail_file = Item.new(Path.new(source_dir.path.to_s + "/thumbnails/#{params[:source]}/#{params[:size]}/#{params[:image]}.jpg"))
    
    thumbnail_exists = false
    if thumbnail_file.exist?
      # check if original file is older than thumbnail, if so replace it
      if File.mtime(original_file.path.to_s) < File.mtime(thumbnail_file.path.to_s)
        thumbnail_exists = true
        # Set thumbnail to return as existing
      end
    end

    # If thumbnail doesn't exist or is old, generate it
    if !thumbnail_exists
      original_file.copy_and_convert_to(thumbnail_file, '50%', 'x700')
    end

    f = File.read(thumbnail_file.path.to_s)
    # Return thumbnail response
    response = {}
    response[:thumbnail] = Base64.encode64(f)
    render json: response, status: 200
  end

end
