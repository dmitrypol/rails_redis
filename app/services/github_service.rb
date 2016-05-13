class GithubService
	def initialize login
		@login = login
	end
 	def perform
  	Rails.cache.fetch("#{self.class.name}/#{__method__}/#{@login}", expires_in: 1.hour) do
 			HTTP.get("https://api.github.com/users/#{@login}").to_s
 		end
 	end
end