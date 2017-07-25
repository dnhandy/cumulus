json.extract! input_file, :id, :job_id, :job_file_id, :created_at, :updated_at
json.url input_file_url(input_file, format: :json)
