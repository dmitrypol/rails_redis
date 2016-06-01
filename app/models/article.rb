class Article < ActiveRecord::Base

  include Redis::Objects
  #value :redobj_attr, marshal: true, expiration: 1.hour
  hash_key :daily_views

  belongs_to :user, counter_cache: true, touch: true
  validates :title, :body, :user, presence: true

  after_create do 			user.redobj_articles_count.incr	 	end
	after_destroy do 			user.redobj_articles_count.decr	 	end
  #after_save do					self.redobj_attr = self.attributes 	end

end
