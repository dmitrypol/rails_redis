class CacheWarmerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    User.all.each do |u|
    	# => this will cache methods on model and in serializer
      u.name
      UserSerializer.new(u).name_serialized
    end
  end
end
