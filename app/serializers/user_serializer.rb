class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email

  def name_serialized
  	# adding class and method names to create unique cache_key
  	Rails.cache.fetch([object.cache_key, self.class.name, __method__]) do
  	  "#{object.name} serialized"
  	end
  end
end
