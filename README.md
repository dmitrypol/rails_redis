# rails_redis
demo app for http://redisconference.com/

basic demo Rails app using Redis for caching and background jobs

git pull

bundle

rake db:migrate

rake db:seed

rails s

http://localhost:3000/

http://localhost:3000/cache and http://localhost:3000/cache/1 - cached controller actions

http://localhost:3000/redis - view stuff in Redis

http://localhost:3000/sidekiq - view your jobs

http://localhost:3000/logs - view logs via logster gem

http://localhost:3000/newrelic - newrelic perf metrics on your code

To run the CacheWarmerJob   rails r CacheWarmerJob.perform_now

To run the WeatherService   rails r "WeatherService.new.perform(94158)"

To run the GithubService   rails r "GithubService.new('dhh').perform"

Also look at show.html.erb, user.rb, user_decorator.rb, user_serializer.rb and cache_controller.rb

