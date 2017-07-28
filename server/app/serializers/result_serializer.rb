class ResultSerializer < ActiveModel::Serializer
  attributes :id, :order, :contents

  belongs_to :job
end
