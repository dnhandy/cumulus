json.extract! job, :id, :status, :job_file_id, :created_at, :updated_at
json.url job_url(job, format: :json)
