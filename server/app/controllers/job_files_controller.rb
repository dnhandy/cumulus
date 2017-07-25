class JobFilesController < ApplicationController
  before_action :set_job_file, only: [:show, :edit, :update, :destroy]

  # GET /job_files
  # GET /job_files.json
  def index
    @job_files = JobFile.all
  end

  # GET /job_files/1
  # GET /job_files/1.json
  def show
  end

  # GET /job_files/new
  def new
    @job_file = JobFile.new
  end

  # GET /job_files/1/edit
  def edit
  end

  # POST /job_files
  # POST /job_files.json
  def create
    @job_file = JobFile.new(job_file_params)

    respond_to do |format|
      if @job_file.save
        format.html { redirect_to @job_file, notice: 'Job file was successfully created.' }
        format.json { render :show, status: :created, location: @job_file }
      else
        format.html { render :new }
        format.json { render json: @job_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /job_files/1
  # PATCH/PUT /job_files/1.json
  def update
    respond_to do |format|
      if @job_file.update(job_file_params)
        format.html { redirect_to @job_file, notice: 'Job file was successfully updated.' }
        format.json { render :show, status: :ok, location: @job_file }
      else
        format.html { render :edit }
        format.json { render json: @job_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_files/1
  # DELETE /job_files/1.json
  def destroy
    @job_file.destroy
    respond_to do |format|
      format.html { redirect_to job_files_url, notice: 'Job file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_job_file
      @job_file = JobFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def job_file_params
      params.require(:job_file).permit(:name, :contents)
    end
end
