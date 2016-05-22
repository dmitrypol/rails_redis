class UserImportJob < ActiveJob::Base
  queue_as :default
  queue_adapter = :sidekiq # => you can customize queue per job

  def perform(row, batch_id)
  	header = JSON.parse REDIS_BATCHES.get("#{batch_id}:header")
	row_hash = Hash[[header, row].transpose]
	result = User.create!(row_hash)
	UserImportService.after_process_record(row: row, result: result: batch_id: batch_id)
  end

end
