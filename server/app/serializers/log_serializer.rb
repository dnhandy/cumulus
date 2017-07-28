class LogSerializer < ActiveModel::Serializer
  attributes :id, :order, :contents

  belongs_to :job
end
