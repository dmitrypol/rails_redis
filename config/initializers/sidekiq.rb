Sidekiq::Web.app_url = '/'

schedule_array =
[
  {'name' => 'CacheWarmerJob', 'class' => 'CacheWarmerJob', 'cron'  => '1 * * * *', 'queue' => 'default', 'active_job' => true }
]

Sidekiq.configure_server do |config|
  config.redis = { host: Rails.application.config.redis_host, post: 6379, db: 0, namespace: 'sidekiq' }
  Sidekiq::Cron::Job.load_from_array! schedule_array
end

Sidekiq.configure_client do |config|
  config.redis = { host: Rails.application.config.redis_host, post: 6379, db: 0, namespace: 'sidekiq' }
end
