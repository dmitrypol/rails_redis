class UserImportJob < ActiveJob::Base
  queue_as :default
  queue_adapter = :sidekiq # => you can customize queue per job

  after_perform do 
  	UserImportService.after_process_record(row: @row, result: @result, batch_id: @batch_id)
  end

  def perform(row, batch_id)
  	@batch_id = batch_id
  	@row = row
  	@header = JSON.parse REDIS_BATCHES.get("#{batch_id}:header")
	row_hash = Hash[[@header, @row].transpose]
	User.create!(row_hash)
	@result = 'success'
  rescue => e
	Rails.logger.error "#{self.class.name}#{__method__} - #{e}"
	@result = 'error'
  end

end
