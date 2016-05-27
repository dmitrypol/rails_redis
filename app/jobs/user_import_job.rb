class UserImportJob < ActiveJob::Base
  queue_as :default
  queue_adapter = :sidekiq # => you can customize queue per job

  after_perform do
  	after_process_record(row: @row, result: @result, batch_id: @batch_id)
  end

  def perform(row, batch_id)
    @row = row
    @batch_id = batch_id
  	header = JSON.parse REDIS_BATCHES.get("#{@batch_id}:header")
  	row_hash = Hash[[header, @row].transpose]
  	User.create!(row_hash)
  	@result = 'success'
  rescue => e
  	Rails.logger.error "#{self.class.name}#{__method__} - #{e}"
  	@result = 'error'
  end

private

  # called after processing each record in batch
  def after_process_record (row: , result: , batch_id: )
    get_batch_params batch_id
    REDIS_BATCHES.rpush(@batch_success, row.to_json) if result == 'success'
    REDIS_BATCHES.rpush(@batch_error, row.to_json) if result == 'error'
    REDIS_BATCHES.decr(@batch_counter)
    after_complete_batch unless REDIS_BATCHES.get(@batch_counter).to_i > 0
  rescue => e
    Rails.logger.error "#{self.name}.#{__method__} - #{e}"
  end

  def get_batch_params batch_id
    @batch_id       = batch_id
    @batch_counter  = "#{@batch_id}:counter"
    @batch_success  = "#{@batch_id}:success"
    @batch_error    = "#{@batch_id}:error"
    @batch_owner_id = "#{@batch_id}:owner_id"
    @batch_header   = "#{@batch_id}:header"
  end

  # => check if batch_size is 0, last job completed
  def after_complete_batch
    # => create output file
    @output_file = "tmp/#{@batch_id.split('_').first}.xlsx"
    package = Axlsx::Package.new
    error_sheet = package.workbook.add_worksheet(name: 'error')
    error_sheet.add_row ['error'] + @header
    success_sheet = package.workbook.add_worksheet(name: 'success')
    success_sheet.add_row @header
    package.serialize (@output_file)

    # => process success and error queues
    REDIS_BATCHES.lrange(@batch_success, 0, -1).each { |record| success_sheet.add_row(JSON.parse(record)) }
    REDIS_BATCHES.lrange(@batch_error, 0, -1).each   { |record| error_sheet.add_row(JSON.parse(record)) }

    # => send file to batch owner
    package.serialize (@output_file)
    subject = "#{REDIS_BATCHES.llen(@batch_success)} success, #{REDIS_BATCHES.llen(@batch_error)} errors"
    # => lookup @batch_owner_id and send email

    # => set expiration for batch keys
    [@batch_counter, @batch_size, @batch_owner_id, @batch_success, @batch_error, @batch_header].each do |key|
      REDIS_BATCHES.expire(key, 1.week)
    end
  rescue => e
    Rails.logger.error "#{self.name}.#{__method__} - #{e}"
  end

end
