class OutputFilesController < ApplicationController
  before_action :set_output_file, only: [:show, :edit, :update, :destroy]

  # GET /output_files
  # GET /output_files.json
  def index
    @output_files = OutputFile.all
  end

  # GET /output_files/1
  # GET /output_files/1.json
  def show
  end

  # GET /output_files/new
  def new
    @output_file = OutputFile.new
  end

  # GET /output_files/1/edit
  def edit
  end

  # POST /output_files
  # POST /output_files.json
  def create
    @output_file = OutputFile.new(output_file_params)

    respond_to do |format|
      if @output_file.save
        format.html { redirect_to @output_file, notice: 'Output file was successfully created.' }
        format.json { render :show, status: :created, location: @output_file }
      else
        format.html { render :new }
        format.json { render json: @output_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /output_files/1
  # PATCH/PUT /output_files/1.json
  def update
    respond_to do |format|
      if @output_file.update(output_file_params)
        format.html { redirect_to @output_file, notice: 'Output file was successfully updated.' }
        format.json { render :show, status: :ok, location: @output_file }
      else
        format.html { render :edit }
        format.json { render json: @output_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /output_files/1
  # DELETE /output_files/1.json
  def destroy
    @output_file.destroy
    respond_to do |format|
      format.html { redirect_to output_files_url, notice: 'Output file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_output_file
      @output_file = OutputFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def output_file_params
      params.require(:output_file).permit(:job_id, :job_file_id)
    end
end
