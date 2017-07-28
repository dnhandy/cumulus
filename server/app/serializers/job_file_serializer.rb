class JobFileSerializer < ActiveModel::Serializer
  attributes :id, :name, :sha1

  def sha1
      Digest::SHA1.hexdigest(object.contents)
  end
end
