class WeatherService
 	def perform zip_code
  	Rails.cache.fetch("#{self.class.name}/#{__method__}/#{zip_code}", expires_in: 1.hour) do
      # call the API
   	end
 	end
end