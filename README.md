# rails_redis
demo app for http://redisconference.com/

basic demo Rails app using Redis for caching and background jobs

git pull

bundle

rake db:migrate

rake db:seed

rails s

http://localhost:3000/

To run the CacheWarmerJob
rails r CacheWarmerJob.perform_now