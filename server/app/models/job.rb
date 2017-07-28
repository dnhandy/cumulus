class Job < ApplicationRecord
  has_one :executable, class_name: "job_file"
  has_one :state_file, class_name: "job_file"

  has_many :results
  has_many :logs

  has_many :inputs, through: :input_files, class_name: "job_file"
  has_many :outputs, through: :output_files, class_name: "job_file"

  enum status: [ :pending, :running, :finished, :cancelling, :cancelled, :pausing, :paused, :resuming ]
end
