require 'pty'
require 'timeout'
require 'open3'

class JobWorker
  include Sidekiq::Worker

  def perform(job_id)
    job = Job.find(job_id)

    if job && (job.pending? || job.resuming?) && job.executable
      initialize_ctx_dir(job)
      cmd = generate_cmd(job)

      begin
        job.running!
        # Start the command!
        log(job_id, "Executing task...",  true)
        stdout, stdin, pid = PTY.spawn(cmd)

        last_processed_line = 0

        finished = false
        thread = Thread.new do
          while (!finished)
            last_processed_line = process_logs(job_id, last_processed_line)

            # The process hasn't ended. Check for commands from the server
            job.reload
            if (job.pausing?)
              log(job_id, "Pausing task...", true)

              child_pid_cmd = "pgrep -P #{pid}"
              Open3.popen3(child_pid_cmd) do |stdin, stdout, stderr, wait_thread|
                child_pid = stdout.gets
                Process.kill('USR1', child_pid.to_i) if child_pid
                tmp_code = wait_thread.value
              end

              begin
                Timeout::timeout(600) do
                  begin
                    while (Process.kill(0, pid))
                      sleep(2)
                    end
                  rescue Errno::ESRCH
                  end
                end
              rescue Timeout::Error
                log(job_id, "Pause timed out. Terminating...", true)
                Process.abort()
              end

              if (job.state_file)
                job.state_file.delete
              end

              if (File.exist?( @state_path ))
                log(job_id, "Saving state...", true)
                state_file = JobFile.new({
                  name: File.basename(@state_path),
                  contents: File.read(@state_path) })
                if (state_file.save)
                  job.update({state_file: state_file})
                end
              end

              job.paused!
            elsif (job.cancelled?)
              log(job_id, "Cancelling task...", true)
              Process.abort()
              job.cancelled!
            end
          end
        end

        begin
          begin
            stdout.each do |line|
              store_result(job_id, line)
            end
          rescue Errno::EIO
          end
        rescue PTY::ChildExited
        end

        Process.waitpid(pid, Process::WNOHANG)
        log(job_id, "Task terminated", true)
        finished = true

        thread.join
        process_logs(job_id, last_processed_line)
      rescue PTY::ChildExited
      end



      if (job.running? || job.paused?)
        log(job_id, "Saving outputs...", true)
        files_to_delete = job.outputs.map{ |x| x.id }
        job.outputs.delete_all
        JobFile.delete(files_to_delete)
        Dir.glob("#{@output_dir}/*").each do |output|
          output_file = JobFile.new({name: File.basename(output), contents: File.read(output) })
          output_file.save
          output_file_bridge = OutputFile.new({job: job, job_file: output_file})
          output_file_bridge.save
        end
      end

      if (job.running?)
        if ($?.exitstatus == 0)
          job.finished!
        else
          job.failed!
        end
      end

      `rm -rf #{@ctx_dir}`
    end
  end

  def generate_cmd(job)
    cmd = "#{@exe_path} -i #{@input_dir} -o #{@output_dir} -s #{@state_path}"
    if (job.resuming?)
      cmd = "#{cmd}  --resume"
    end

    cmd = "#{cmd} 2>#{@log_path}"

    return cmd
  end

  def initialize_ctx_dir(job)
    log(job.id, "Creating working directory...", true)
    @ctx_dir = "/tmp/#{SecureRandom.urlsafe_base64}"
    @exe_path = "#{@ctx_dir}/exe"
    @state_path = "#{@ctx_dir}/state"
    @log_path = "#{@ctx_dir}/log"
    @input_dir = "#{@ctx_dir}/input"
    @output_dir = "#{@ctx_dir}/output"

    `mkdir #{@ctx_dir}`
    `mkdir #{@input_dir}`
    `mkdir #{@output_dir}`
    `touch #{@log_path}`

    # Write the executable and change its permissions
    File.open(@exe_path, 'wb') { |file| file.write(job.executable.contents) }
    `chmod +x #{@exe_path}`

    # Write the input files
    job.inputs.each do |input_file|
      path = "#{@input_dir}/#{input_file.name}"
      File.open(path, 'wb') { |file| file.write(input_file.contents) }
    end

    # if the job is being resumed after being previously paused, copy the state
    # file and output files as well
    if (job.resuming? && job.state_file)
      File.open(@state_path, 'wb') { |file| file.write(job.state_file.contents) }

      job.outputs.each do |output_file|
        path = "#{@output_dir}/#{output_file.name}"
        File.open(path, 'wb') { |file| file.write(output_file.contents) }
      end
    end
  end

  def process_logs(job_id, last_processed_line)
    current_line = 0
    File.foreach(@log_path) do |log_line|
      current_line = current_line + 1
      if (current_line > last_processed_line)
        log(job_id, log_line)
        last_processed_line = current_line
      end
    end

    return last_processed_line
  end

  def store_result(job_id, result)
    result = Result.new({ job_id: job_id, contents: result })
    result.save
  end

  def log(job_id, log_msg, internal = false)
    #Do a separate lookup here because threads.
    job = Job.find(job_id)
    if (job)
      log_entry = Log.new({
         job_id: job.id,
         contents: log_msg,
         application: internal ? "cumulus" : job.executable.name })
      log_entry.save()
    end
  end
end
