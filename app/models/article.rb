class Article < ActiveRecord::Base

  include Redis::Objects
  #value :redobj_attr, marshal: true, expiration: 1.hour
  hash_key :daily_views

  belongs_to :user, counter_cache: true, touch: true
  validates :title, :body, :user, presence: true

  after_create do 			user.redobj_articles_count.incr	 	end
	after_destroy do 			user.redobj_articles_count.decr	 	end
  #after_save do					self.redobj_attr = self.attributes 	end

  # query mongo collection for stats for this article by article_id
  def mongo_daily_views
  	ARTICLE_DAILY_VIEWS.find(:article_id => id).projection(:article_id => 0, :_id => 0).first
  end

end
