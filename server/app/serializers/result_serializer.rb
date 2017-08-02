class ResultSerializer < ActiveModel::Serializer
  attributes :id, :contents, :created_at, :updated_at
end
