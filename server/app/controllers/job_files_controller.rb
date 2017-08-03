require 'data_uri'
require 'base64'

class JobFilesController < ApplicationController
  before_action :set_job_file, only: [:show, :download, :destroy]

  # GET /job_files
  def index
    @job_files = JobFile.all
    render json: @job_files
  end

  # GET /job_files/inputs
  def inputs
    render json: InputFile.all.select{ |x| x.job_file }.map{ |x| x.job_file }.uniq
  end

  # GET /job_files/executables
  def executables
    render json: Job.all.select{ |x| x.executable }.map{ |x| x.executable }.uniq
  end

  # GET /job_files/1
  def show
    render json: @job_file
  end

  #GET /job_files/1/download
  def download
    send_data @job_file.contents, filename: @job_file.name, type: "application/octet-stream"
  end

  # POST /job_files
  def create
    begin
      @job_file = JobFile.new(job_file_params)
      encoding = params.permit(:encoding)[:encoding]
      if (@job_file.contents)
        case encoding
        when "base64"
          @job_file.contents = Base64.decode64(@job_file.contents)
        when "datauri"
          uri = URI::Data.new(@job_file.contents)
          @job_file.contents = uri.data
        else
        end
      end

      if @job_file.save
        render json: @job_file
      else
        render json: @job_file.errors, status: :unprocessable_entity
      end
    rescue
      puts "Exception raised creating new file: \"#{$!.message}\""
      raise
    end
  end

  # DELETE /job_files/1
  def destroy
    @job_file.destroy
    head :no_content
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job_file
      @job_file = JobFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_file_params
      p = params.require(:job_file).permit(:name, :contents)
    end
end
