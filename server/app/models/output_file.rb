class OutputFile < ApplicationRecord
  belongs_to :job
  belongs_to :job_file
end
