class QueueManager
  MAXIMUM_PROCESSES = 1 # Sets maximum allowed processes at the same time

  def run

    Rails.logger.info "Running queue manager"
    # Fork process to allow calling method to finish
    pid = fork do

      Rails.logger.info "Created a new instance of queue manager (fork)"

      redis = RedisInterface.new

      # Check if there are any running processes
      running_keys = redis.keys("dFile:processes:*:state:running")
      if running_keys && running_keys.count >= MAXIMUM_PROCESSES
        Rails.logger.info "There are already processes running: #{running_keys.to_json} , aborting!"
        Process.exit!
      end

      # Check if there are any queued processes
      queued_keys = redis.keys("dFile:processes:*:state:queued")
      if queued_keys.empty?
        Rails.logger.info "There are no queued processes, aborting!"
        Process.exit!
      end

      # Parse queued processes
      queued_processes = []
      queued_keys.each do |key|
        process_id = redis.get(key)
        process_object = {
          id: process_id,
          process: redis.get("dFile:processes:#{process_id}:process"),
          params: JSON.parse(redis.get("dFile:processes:#{process_id}:params")),
          priority: redis.get("dFile:processes:#{process_id}:priority")
        }
        queued_processes << process_object

      end

      # Sort based on priority
      queued_processes.sort! { |a,b| a[:priority] <=> b[:priority] }

      # Choose the first process to run
      @process = queued_processes.first

      Rails.logger.info "Selected process for execution: #{@process.to_json}"

      # Make sure process is still queued
      if redis.get("dFile:processes:#{@process[:id]}:state:queued").nil?
        Rails.logger.info "Process is no longer in queued state, aborting!"
        Process.exit!
      end

      redis.transaction do
        # Remove queued key and create running key
        redis.set("dFile:processes:#{@process[:id]}:state:running", @process[:id])
        redis.del("dFile:processes:#{@process[:id]}:state:queued")

      end #End redis transaction

      Rails.logger.info "Staring process #{@process[:process]} for id: #{@process[:id]}"

      # Run the process
      case @process[:process]
      when "CHECKSUM"
        checksum(key_root: "dFile:processes:#{@process[:id]}:")
      end

      # Set state to done
      redis.del("dFile:processes:#{@process[:id]}:state:running")
      redis.set("dFile:processes:#{@process[:id]}:state:done", @process[:id])
      redis.set("dFile:processes:#{@process[:id]}:state", "DONE")

      Rails.logger.info "########### Process done! ############"

      # Run QueueManager again to continue picking processes from queue
      QueueManager.new.run
    end
  end

  # Calcluates a checksum for given source_file and sets result key
  def checksum(key_root:)
    source_file = Item.new(Path.new(@process[:params]['source_file']))
    redis = RedisInterface.new

    Rails.logger.info "CHECKSUM: Source file: #{source_file.path.to_s}"

    # If file does not exist, create error key and message
    if !source_file.path.exist?
      Rails.logger.error "CHECKSUM: Source file #{source_file.path.to_s} does not exist!"
      redis.set(key_root + 'error', "CHECKSUM: Source file #{source_file.path.to_s} does not exist!")
      redis.set(key_root + 'value', "error")
      return
    end

    begin
      checksum = FileManager.checksum(source_file.path)
      redis.set(key_root + 'value', checksum)
    rescue StandardError => e
      redis.set(key_root + 'value', "error")
      redis.set(key_root + 'error', e.inspect)
    end
  end
end
