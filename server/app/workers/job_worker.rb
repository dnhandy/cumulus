require 'pty'
require 'timeout'

class JobWorker
  include Sidekiq::Worker

  def perform(*args)
    job = Job.find(job_id)

    if job && (job.pending? || job.resumed?) && job.executable
      ctx_dir = "/tmp/#{SecureRandom.urlsafe_base64}"
      exe_path = "#{ctx_dir}/exe"
      state_path = "#{ctx_dir}/state"
      log_path = "#{ctx_dir}/log"
      input_dir = "#{ctx_dir}/input"
      output_dir = "#{ctx_dir}/output"


      `mkdir #{ctx_dir}`

      File.open(exe_path, 'wb') { |file| file.write(job.executable.contents) }
      `chmod +x #{exe_path}`

      `mkdir #{input_dir}`
      `mkdir #{output_dir}`

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

      var cmd = "#{exe_path} -i #{input_dir} -o #{output_dir} -s #{state_path}"
      if (job.resuming?)
        cmd = "#{cmd}  --resume"
      end

      cmd = "#{cmd} 2>#{log_path}"

      begin

        stdout, stdin, pid = PTY.spawn(cmd)

        job.running!
        thread = Thread.new do
          begin
            begin
              line_num = job.outputs.count + 1
              stdout.each do |line|
                result = Result.new()
                result.update( { job_id: job.id, order: line_num, contents: line } )
                line_num = line_num + 1
              end
            rescue Errno::EIO
            end
          rescue
            PTY::ChildExited
          end
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
            Process.abort("Task aborted by user")
            job.cancelled!
          end
        end

        thread.join
      rescue PTY::ChildExited

      end

      if (File.exist?(log_path))
        log_number = job.logs.count + 1
        File.open(log_path) do |log_file|
          log_file.each_line do |log_line|
            log_entry = new Log()
            log_entry.update({job_id: job.id, order: log_number, contents: log_line })
            log_number = log_number + 1
          end
        end
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
    end
  end
end
