class User < ActiveRecord::Base

	def name
	  # adding method name to create unique cache_key
	  Rails.cache.fetch("#{cache_key}/#{__method__}") do
		"#{first_name} #{last_name}"
	  end
	end
	
end
