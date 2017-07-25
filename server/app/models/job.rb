class Job < ApplicationRecord
  has_one :executable, class_name: "job_file"
  has_one :state_file, class_name: "job_file"

  has_many :results
  has_many :logs

  enum status [ :pending, :running, :finished, :cancelling, :cancelled, :pausing, :paused, :resuming ]
end
