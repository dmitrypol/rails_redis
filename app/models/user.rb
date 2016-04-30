class User < ActiveRecord::Base

	def name
	  Rails.cache.fetch("#{cache_key}/#{__method__}") do
		"#{first_name} #{last_name}"
	  end
	end
	
end
