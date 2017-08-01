class Job < ApplicationRecord
  belongs_to :executable, class_name: "JobFile"
  belongs_to :state_file, class_name: "JobFile", optional: true

  has_many :results
  has_many :logs

  has_many :input_files
  has_many :output_files

  has_many :inputs, through: :input_files, source: :job_file
  has_many :outputs, through: :output_files, source: :job_file

  enum status: [ :pending, :running, :finished, :cancelled, :pausing, :paused, :resuming, :failed ]
end
