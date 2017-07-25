require 'test_helper'

class OutputFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @output_file = output_files(:one)
  end

  test "should get index" do
    get output_files_url
    assert_response :success
  end

  test "should get new" do
    get new_output_file_url
    assert_response :success
  end

  test "should create output_file" do
    assert_difference('OutputFile.count') do
      post output_files_url, params: { output_file: { job_file_id: @output_file.job_file_id, job_id: @output_file.job_id } }
    end

    assert_redirected_to output_file_url(OutputFile.last)
  end

  test "should show output_file" do
    get output_file_url(@output_file)
    assert_response :success
  end

  test "should get edit" do
    get edit_output_file_url(@output_file)
    assert_response :success
  end

  test "should update output_file" do
    patch output_file_url(@output_file), params: { output_file: { job_file_id: @output_file.job_file_id, job_id: @output_file.job_id } }
    assert_redirected_to output_file_url(@output_file)
  end

  test "should destroy output_file" do
    assert_difference('OutputFile.count', -1) do
      delete output_file_url(@output_file)
    end

    assert_redirected_to output_files_url
  end
end
