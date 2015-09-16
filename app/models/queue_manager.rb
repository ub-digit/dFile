class QueueManager
  MAXIMUM_PROCESSES = 1 # Sets maximum allowed processes at the same time

  def run

    # Fork process to allow calling method to finish
    pid = fork do

      redis = RedisInterface.new

      # Check if process picking is locked
      if redis.get("dFile:processes:locked") == 'true'
        Process.exit!
      end

      # Check if there are any running processes
      running_keys = redis.keys("dFile:processes:*:state:running")
      if running_keys && running_keys.count >= MAXIMUM_PROCESSES
        Process.exit!
      end

      # Lock queue picking from other processes
      redis.set("dFile:processes:locked", 'true')

      # Check if there are any queued processes
      queued_keys = redis.keys("dFile:processes:*:state:queued")
      if queued_keys.empty?
        redis.set("dFile:processes:locked", 'false')
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
      
      # Remove queued key and create running key
      redis.set("dFile:processes:#{@process[:id]}:state:running", @process[:id])
      redis.del("dFile:processes:#{@process[:id]}:state:queued")

      # Unlock queue picking process
      redis.set("dFile:processes:locked", 'false')

      # Run the process
      case @process[:process]
      when "CHECKSUM"
        checksum(key_root: "dFile:processes:#{@process[:id]}:")
      end

      # Set state to done
      redis.del("dFile:processes:#{@process[:id]}:state:running")
      redis.set("dFile:processes:#{@process[:id]}:state:done", @process[:id])
      redis.set("dFile:processes:#{@process[:id]}:state", "DONE")

      # Run QueueManager again to continue picking processes from queue
      QueueManager.new.run
    end
  end

  # Calcluates a checksum for given source_file and sets result key
  def checksum(key_root:)
    source_file = Item.new(Path.new(@process[:params]['source_file']))
    redis = RedisInterface.new

    # If file does not exist, create error key and message
    if !source_file.path.exist?
      redis.set(key_root + 'error', "CHECKSUM: Source file #{source_file.path.to_s} does not exist!")
    end

    checksum = FileManager.checksum(source_file.path)

    redis.set(key_root + 'value', checksum)
  end
end
