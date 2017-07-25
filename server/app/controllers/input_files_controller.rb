class InputFilesController < ApplicationController
  before_action :set_input_file, only: [:show, :edit, :update, :destroy]

  # GET /input_files
  # GET /input_files.json
  def index
    @input_files = InputFile.all
  end

  # GET /input_files/1
  # GET /input_files/1.json
  def show
  end

  # GET /input_files/new
  def new
    @input_file = InputFile.new
  end

  # GET /input_files/1/edit
  def edit
  end

  # POST /input_files
  # POST /input_files.json
  def create
    @input_file = InputFile.new(input_file_params)

    respond_to do |format|
      if @input_file.save
        format.html { redirect_to @input_file, notice: 'Input file was successfully created.' }
        format.json { render :show, status: :created, location: @input_file }
      else
        format.html { render :new }
        format.json { render json: @input_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /input_files/1
  # PATCH/PUT /input_files/1.json
  def update
    respond_to do |format|
      if @input_file.update(input_file_params)
        format.html { redirect_to @input_file, notice: 'Input file was successfully updated.' }
        format.json { render :show, status: :ok, location: @input_file }
      else
        format.html { render :edit }
        format.json { render json: @input_file.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /input_files/1
  # DELETE /input_files/1.json
  def destroy
    @input_file.destroy
    respond_to do |format|
      format.html { redirect_to input_files_url, notice: 'Input file was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_input_file
      @input_file = InputFile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def input_file_params
      params.require(:input_file).permit(:job_id, :job_file_id)
    end
end
