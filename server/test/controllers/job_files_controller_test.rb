require 'test_helper'

class JobFilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @job_file = job_files(:one)
  end

  test "should get index" do
    get job_files_url
    assert_response :success
  end

  test "should get new" do
    get new_job_file_url
    assert_response :success
  end

  test "should create job_file" do
    assert_difference('JobFile.count') do
      post job_files_url, params: { job_file: { contents: @job_file.contents, name: @job_file.name } }
    end

    assert_redirected_to job_file_url(JobFile.last)
  end

  test "should show job_file" do
    get job_file_url(@job_file)
    assert_response :success
  end

  test "should get edit" do
    get edit_job_file_url(@job_file)
    assert_response :success
  end

  test "should update job_file" do
    patch job_file_url(@job_file), params: { job_file: { contents: @job_file.contents, name: @job_file.name } }
    assert_redirected_to job_file_url(@job_file)
  end

  test "should destroy job_file" do
    assert_difference('JobFile.count', -1) do
      delete job_file_url(@job_file)
    end

    assert_redirected_to job_files_url
  end
end
