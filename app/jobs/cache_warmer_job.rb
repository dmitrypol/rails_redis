class CacheWarmerJob < ActiveJob::Base
  queue_as :default

  def perform(*args)
    User.all.each do |u|
      u.name
      UserSerializer.new(u).name_serialized
    end
  end
end
