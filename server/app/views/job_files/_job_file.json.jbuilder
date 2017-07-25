json.extract! job_file, :id, :name, :contents, :created_at, :updated_at
json.url job_file_url(job_file, format: :json)
