class ArticleDailyViewsJob < ActiveJob::Base
  queue_as :low

  # => in real application this will process some kind of logs and show stats into redis
  def perform(article, time)
  	article.daily_views.incr(time.to_date, 1)
  end
end
