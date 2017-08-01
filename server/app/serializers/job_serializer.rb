class JobSerializer < ActiveModel::Serializer
  attributes :id, :status, :name

  has_one :executable
  has_one :state_file

  has_many :inputs
  has_many :outputs
end
