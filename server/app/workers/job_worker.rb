require 'pty'

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
      if (job.resumed?)
        cmd = "#{cmd}  --resume"
      end

      cmd = "#{cmd} 2>#{log_path}"

      begin

        stdout, stdin, pid = PTY.spawn(cmd)
        normal_exit = true

        thread = Thread.new do
          begin
            begin
              line_num = 1
              stdout.each do |line|
                result = Result.new { job_id: job.id, order: line_num, contents: line }
                result.save
                line_num++
              end
            rescue Errno::EIO
            end
          rescue
            PTY::ChildExited
          end
        end

        while (Process.kill(0, pid))
          sleep(5)
          job.reload

          if (job.paused?)
            Process.kill('USR1', pid)
            #TODO: save the state
            break
          end
        end

        thread.join

      rescue PTY::ChildExited

      end



      if (normal_exit)
        job.complete!
      end
    end
  end
end

# class CyclusWorker
#   include Sidekiq::Worker
#
#   def get_sha1(path)
#     `sha1sum #{path}`.split(" ")[0]
#   end
#
#   def perform(job_id)
#     begin
#       job = Job.find(job_id)
#
#       if (job && job.input_file)
#         job.update(status: 'Started')
#
#         path = nil
#         delete_path = false
#
#         # First check to see if it's a permanent cyclus file
#         if (
#           job.input_file.path &&
#           File.exist?(job.input_file.path) &&
#           get_sha1(job.input_file.path) == job.input_file.sha1)
#         then
#           path = job.input_file.path
#         end
#
#         # If not, see if it's a permanent custom file that's already been
#         # uploaded to this worker
#         if (!path && job.input_file.contents)
#           shaPath = "/tmp/#{job.input_file.sha1}.xml"
#
#           if (File.exist?(shaPath) && get_sha1(shaPath) == job.input_file.sha1)
#             path = shaPath
#           end
#
#           if (!path)
#             job.update(status: 'Retrieving input file')
#             File.open(shaPath, 'w') { |file| file.write(job.input_file.contents) }
#             path = shaPath
#             delete_path = job.input_file.temporary
#           end
#         end
#
#         if (path)
#           job.update(status: 'Executing cyclus')
#           output_file = "/tmp/#{job_id}.sqllite"
#           if system( "cyclus -o #{output_file} #{path}" )
#             job.output_file = File.read(output_file);
#             job.status = "Complete"
#             job.save()
#           else
#             job.update(status: 'Error executing cyclus')
#           end
#
#           if (delete_path)
#             File.delete(path)
#           end
#         else
#           job.update(status: 'Input file not found')
#         end
#       end
#     rescue
#
#     end
#   end
# end
