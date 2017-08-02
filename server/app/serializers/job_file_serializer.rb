class JobFileSerializer < ActiveModel::Serializer
  attributes :id, :name, :sha1, :created_at, :updated_at

  def sha1
      Digest::SHA1.hexdigest(object.contents)
  end
end
