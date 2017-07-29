class Job < ApplicationRecord
  belongs_to :executable, class_name: "JobFile"
  belongs_to :state_file, class_name: "JobFile", optional: true

  has_many :results
  has_many :logs

  has_many :inputs, through: :input_files, class_name: "JobFile"
  has_many :outputs, through: :output_files, class_name: "JobFile"

  enum status: [ :pending, :running, :finished, :cancelling, :cancelled, :pausing, :paused, :resuming, :failed ]
end
