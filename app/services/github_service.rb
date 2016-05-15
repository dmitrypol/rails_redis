class GithubService
	def initialize user
		@user = user
	end
 	def perform
 		# creating unique cache key from class name, method name and user
  	Rails.cache.fetch([self.class.name, __method__, @user.cache_key], expires_in: 1.hour) do
 			HTTP.get("https://api.github.com/users/#{@user.github_login}").to_s
 		end
 	end
end