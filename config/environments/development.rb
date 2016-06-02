Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Asset digests allow you to set far-future HTTP expiration dates on all assets,
  # yet still be able to expire them through the digest params.
  config.assets.digest = true

  # Adds additional error checking when serving assets at runtime.
  # Checks for improperly declared sprockets dependencies.
  # Raises helpful error messages.
  config.assets.raise_runtime_errors = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # =>
  config.action_controller.perform_caching = true
  config.redis_host = 'localhost'
  config.cache_store = :readthis_store, { expires_in: 1.hour, namespace: 'mycache', redis: { host: config.redis_host, port: 6379, db: 0 }, driver: :hiredis }

  config.active_job.queue_adapter = :sidekiq

  REDIS_BATCHES = Redis::Namespace.new(:batches, redis: Redis.new(host: Rails.application.config.redis_host, port: 6379, db: 0, driver: :hiredis) )

  Logster.store = Logster::RedisStore.new(Redis.new(host: Rails.application.config.redis_host, port: 6379, db: 1, driver: :hiredis))

  settings = {"connections"=>{
    "default"=>{"url"=>"redis://#{config.redis_host}:6379/0"},
    "db1"    =>{"url"=>"redis://#{config.redis_host}:6379/1"},
    }}
  RedisBrowser.configure(settings)

  MONGO_CLIENT = Mongo::Client.new([ '127.0.0.1:27017' ], database: 'rails_redis')
  ARTICLE_DAILY_VIEWS = MONGO_CLIENT[:article_daily_views]

end
