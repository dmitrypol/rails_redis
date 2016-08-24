class UserGeocodeJob < ApplicationJob
  queue_as :low

  def perform(user)
  	result = get_data(user.zipcode).first
  	user.update!(lat: result.latitude, lng: result.longitude)
  end

private

	def get_data zipcode
  	Rails.cache.fetch([self.class.name, __method__, zipcode], expires_in: 1.week) do
  		Geocoder.search(zipcode)
  	end
	end

end
