# rails_redis
demo app for http://redisconference.com/

basic demo Rails app using Redis for caching and background jobs

git pull

bundle

rake db:migrate

rake db:seed

rails s

http://localhost:3000/

To run the CacheWarmerJob   rails r CacheWarmerJob.perform_now

To run the WeatherService   rails r "WeatherService.new.perform(94158)"

Also look at show.html.erb, user.rb, user_decorator.rb and user_serializer.rb

Browse to http://localhost:3000/redis and http://localhost:3000/sidekiq
