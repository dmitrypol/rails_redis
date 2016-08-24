class ArticleDailyViewsJob < ApplicationJob
  queue_as :low

  # => in real application this will process some kind of input (log file or http request)
  def perform(article, time)
  	# =>  push stats into redis
  	article.daily_views.incr(time.to_date, 1)
  	# =>  push stats into mongo
  	ARTICLE_DAILY_VIEWS.update_one( {article_id: article.id}, { "$inc" => { :"#{time.to_date}" => 1 } }, :upsert => true )
  end
end
