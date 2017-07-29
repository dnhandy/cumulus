class JobsController < ApplicationController
  before_action :set_job, only: [:show, :pause, :resume, :cancel, :destroy]

  # GET /jobs
  def index
    begin
      @jobs = Job.all
      render json: @jobs
    rescue
      logger.warn "Exception raised listing jobs: \"#{$!.message}\""
    end
  end

  # GET /jobs/1
  def show
    begin
      render json: @job
    rescue
      logger.warn "Exception raised showing job: \"#{$!.message}\""
    end
  end

  # POST /jobs
  def create
    begin
      executable_id = params.permit(:executable_id)[:executable_id]
      input_file_ids = params.permit(:input_file_ids)[:input_file_ids]
      if (executable_id)
        executable = JobFile.find(executable_id)
        if executable
          @job = Job.new(job_params)
          @job.status = :pending
          @job.executable = executable
          if input_file_ids
            input_file_ids.each do |file_id|
              file = JobFile.find(file_id)
              @job.inputs << file if file
            end
          end
          if @job.save
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
    rescue
      logger.warn "Exception raised creating new job: \"#{$!.message}\""
      raise
    end
  end

  # PATCH /jobs/1/pause
  def pause
    if @job.running? || @job.pending?
      @job.pausing!
      head :no_content
    else
      head 403
    end
  end

  # PATCH /jobs/1/resume
  def resume
    if @job.paused?
      @job.resuming!
      JobWorker.perform_async(@job.id)
      head :no_content
    else
      head 403
    end
  end

  # PATCH /jobs/1/cancel
  def cancel
    if (@job.pending || @job.running? || @job.pausing? || @job.paused? || @job.resuming?)
      @job.cancelling!
      head :no_content
    else
      head 403
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
      params.require(:job).permit(:executable_id)
    end
end
