class Article < ActiveRecord::Base

  belongs_to :user, counter_cache: true
  validates :title, :body, :user, presence: true

  after_create do 			user.redobj_articles_count.incr	 	end
	after_destroy do 			user.redobj_articles_count.decr	 	end

end
