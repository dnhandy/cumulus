class LogSerializer < ActiveModel::Serializer
  attributes :id, :contents, :application, :created_at, :updated_at
end
