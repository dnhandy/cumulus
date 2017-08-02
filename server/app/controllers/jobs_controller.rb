class JobsController < ApplicationController
  before_action :set_job, only: [:show, :results, :logs, :pause, :resume, :cancel, :destroy]

  # GET /jobs
  def index
    @jobs = Job.all
    render json: @jobs
  end

  # GET /jobs/1
  def show
    render json: @job
  end

  # GET /jobs/1/results
  def results
    render json: @job.results
  end

  # GET /jobs/1/logs
  def logs
    render json: @job.logs
  end

  # POST /jobs
  def create
    executable_id = params.permit(:executable_id)[:executable_id]
    input_file_ids = params.permit(inputs: [])[:inputs]
    if (executable_id)
      executable = JobFile.find(executable_id)
      if executable
        @job = Job.new(job_params)
        @job.status = :pending
        @job.executable = executable

        if @job.save
          if input_file_ids
            input_file_ids.each do |file_id|
              file = JobFile.find(file_id)
              if file
                input_file = InputFile.new({job: @job, job_file: file})
                input_file.save
              end
            end
          end

          JobWorker.perform_async(@job.id)
          render json: @job
        else
          render json: @job.errors, status: :unprocessable_entity
        end
      else
        render json: {"errors": ["Executable '#{executable_id}' not found"]}, status: 400
      end
    else
      render json: {"errors": ["Executable ID required"]}, status: 400
    end
  end

  # PATCH /jobs/1/pause
  def pause
    begin
      if @job.running? || @job.pending?
        if @job.running?
          @job.pausing!
        else
          @job.paused!
        end
        head :no_content
      else
        head 403
      end
    rescue
      puts $!
    end
  end

  # PATCH /jobs/1/resume
  def resume
    begin
      if @job.paused?
        @job.resuming!
        JobWorker.perform_async(@job.id)
        head :no_content
      else
        head 403
      end
    rescue
      puts $!
    end
  end

  # PATCH /jobs/1/cancel
  def cancel
  begin
    if (@job.pending? || @job.running? || @job.pausing? || @job.paused? || @job.resuming?)
      @job.cancelled!
      head :no_content
    else
      head 403
    end
  rescue
    puts $!
  end
  end

  # DELETE /jobs/1
  def destroy
    @job.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_params
      params.require(:job).permit(:executable_id, :name)
    end
end
