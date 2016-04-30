class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email

  def name_serialized
  	Rails.cache.fetch("#{object.cache_key}/#{self.class.name}/#{__method__}") do
  	  "#{object.name} serialized"
  	end
  end
end
