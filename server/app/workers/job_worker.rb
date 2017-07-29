require 'pty'
require 'timeout'

class JobWorker
  include Sidekiq::Worker

  def perform(job_id)
    job = Job.find(job_id)

    if job && (job.pending? || job.resumed?) && job.executable

      # Set up the various files and directories
      ctx_dir = "/tmp/#{SecureRandom.urlsafe_base64}"
      exe_path = "#{ctx_dir}/exe"
      state_path = "#{ctx_dir}/state"
      log_path = "#{ctx_dir}/log"
      input_dir = "#{ctx_dir}/input"
      output_dir = "#{ctx_dir}/output"

      `mkdir #{ctx_dir}`
      `mkdir #{input_dir}`
      `mkdir #{output_dir}`
      `touch #{log_path}`

      # Write the executable and change its permissions
      File.open(exe_path, 'wb') { |file| file.write(job.executable.contents) }
      `chmod +x #{exe_path}`

      # Write the input files
      job.input_files.each do |input_file|
        path = "#{input_dir}/input_file.name"
        File.open(path, 'wb') { |file| file.write(input_file.contents) }
      end

      # if the job is being resumed after being previously paused, copy the state
      # file and output files as well
      if (job.resumed? && job.state_file)
        File.open(state_path, 'wb') { |file| file.write(job.state_file.contents) }

        job.output_files.each do |input_file|
          path = "#{output_dir}/input_file.name"
          File.open(path, 'wb') { |file| file.write(input_file.contents) }
        end
      end

      # Now build the command
      var cmd = "#{exe_path} -i #{input_dir} -o #{output_dir} -s #{state_path}"
      if (job.resuming?)
        cmd = "#{cmd}  --resume"
      end

      cmd = "#{cmd} 2>#{log_path}"

      begin
        stdout, stdin, pid = PTY.spawn(cmd)

        job.running!
        # Create the main runner thread
        runner_thread = Thread.new do
          begin
            begin
              stdout.each do |line|
                result = Result.new()
                result.update( { job_id: job.id, contents: line } )
              end
            rescue Errno::EIO
            end
          rescue PTY::ChildExited
          end
        end

        #Create a thread to monitor logging through INotify
        notifier_thread = Thread.new do
          last_processed_line = 0
          notifier = INotify::Notifier.new
          notifier.watch(log_path, :modify) do
            current_line = 0;
            File.foreach(log_path) do |log_line|
              current_line = current_line + 1
              if (current_line > last_processed_line)
                log(job.id, log_line)
              end
            end
          end

          while (Process.kill(0, pid))
            if IO.select([notifier.to_io], [], [], 2)
              notifier.process
            end
          end
          notifier.process
          notifier.close
        end

        # Process.kill(0, pid) sends a signal of 0 to the process, which
        # returns 1 if the process still exists.
        while (Process.kill(0, pid))
          sleep(5)
          job.reload

          if (job.pausing?)
            Process.kill('USR1', pid)
            Timeout::timeout(600) do
              while (Process.kill(0, pid))
                sleep(0.5)
              end
            end
            if (Process.kill(0, pid))
              Process.abort("Timed out while attempting to pause")
            end

            if (job.state_file)
              job.state_file.delete
            end

            if (File.exist?( state_path ))
              job.state_file = new JobFile({name: File.basename(state_path), contents: File.read(state_path) })
              job.state_file.save
            end

            job.paused!
            break
          elsif (job.cancelling?)
            Process.abort("Task cancelled by user")
            job.cancelled!
          end
        end

        runner_thread.join
        notifier_thread.join
      rescue PTY::ChildExited
      end

      if (job.running? || job.paused?)
        files_to_delete = job.output_files.map{ |x| x.id }
        job.output_files.delete_all
        JobFile.delete(files_to_delete)
        Dir.glob("#{output_dir}/*").each do |output|
          output_file = new JobFile({name: File.basename(output), contents: File.read(output) })
          output_file.save
          output_file_bridge = new OutputFile({job: job, job_file: output_file})
          output_file_bridge.save
        end
      end

      if (job.running?)
        job.complete!
      end

      `rm -rf #{ctx_dir}`
    end
  end

  def log(job, log_msg)
    log_entry = new Log()
    log_entry.update({job: job, contents: log_msg })
  end
end
