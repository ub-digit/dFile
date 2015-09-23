class QueueManager
  MAXIMUM_PROCESSES = 1 # Sets maximum allowed processes at the same time
  MAXIMUM_FORKS = 5 # Sets maximum of concurrent forks allowed to start

  def run

    redis = RedisInterface.new
    forks_count = redis.get("dFile:forks") || "0"
    if forks_count.to_i > MAXIMUM_FORKS
      Rails.logger.info "FORKS: Maximum number of allowed forks reached #{MAXIMUM_FORKS}, aborting!"
      return
    end

    Rails.logger.info "Running queue manager"
    # Fork process to allow calling method to finish
    pid = fork
    if pid.nil?

      Rails.logger.info "Created a new instance of queue manager (fork)"

      redis = RedisInterface.new
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
        @process = queued_processes.first

        Rails.logger.info "Selected process for execution: #{@process.to_json}"

        # Make sure process is still queued
        if redis.get("dFile:processes:#{@process[:id]}:state:queued").nil?
          Rails.logger.info "Process is no longer in queued state, aborting!"
          exit_fork
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

      end
    else
      # Parent process
      Process.detach(pid)
    end
  end

  def exit_fork(state = :aborted)
    Rails.logger.info "FORK: Exiting process #{Process.pid} (#{state})"
    redis = RedisInterface.new
    redis.decr("dFile:forks")
    Process.exit!
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
