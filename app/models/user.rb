class User < ActiveRecord::Base
  
  include Redis::Objects
  counter :redobj_articles_count

  validates :first_name, :last_name, :email, presence: true
  #validates :email, uniqueness: true

  has_many :articles

  after_update do
		UserGeocodeJob.perform_later(self) if zipcode.present? and zipcode_changed?
 	end

	def name
	  # adding method name to create unique cache_key
	  Rails.cache.fetch([cache_key, __method__]) do
			"#{first_name} #{last_name}"
	  end
	end

end
