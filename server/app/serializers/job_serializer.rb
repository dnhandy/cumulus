class JobSerializer < ActiveModel::Serializer
  attributes :id, :status, :name, :created_at, :updated_at

  has_one :executable
  has_one :state_file

  has_many :input_files
  has_many :outputs
end
