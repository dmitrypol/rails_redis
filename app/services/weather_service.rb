class WeatherService
 	def perform zip_code
 	# create cache key based on zipcode, different users can share zipcode
  	Rails.cache.fetch("#{self.class.name}/#{__method__}/#{zip_code}", expires_in: 1.hour) do
      appid = ENV.fetch('openweathermap_appid')
      url = "http://api.openweathermap.org/data/2.5/weather?zip=#{zip_code},us&appid=#{appid}"
      HTTP.get(url).to_s
   	end
 	end
end