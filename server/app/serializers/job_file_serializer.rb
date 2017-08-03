class JobFileSerializer < ActiveModel::Serializer
  attributes :id, :name, :sha1, :created_at, :updated_at

  def sha1
    if (object.contents)
      return Digest::SHA1.hexdigest(object.contents)
    else
      return nil
    end
  end
end
