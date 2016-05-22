class UserImportService

	def initialize file, batch_owner
		@file = file
		@batch_owner = batch_owner
		@batch_id = "#{Time.now.to_i}_#{@batch_owner.id}"
	end

	def perform
		return 'Must provide file' if @file.blank?
		upload_spreadsheet = open_spreadsheet
		return 'File must be XLSX format' if upload_spreadsheet == false
		# => check file size
		num_rows = upload_spreadsheet.last_row
		max_rows = 1000000
		return "Too many rows, max size is #{max_rows}" if num_rows > max_rows

		header = upload_spreadsheet.row(1)
		setup_batch_params num_rows - 1, header
	    (2..num_rows).each do |i|
	     	row = upload_spreadsheet.row(i)
	     	UserImportJob.perform_later(row, @batch_id)
	    end
		return 'user import process began'
	end

  # called after processing each record in batch
  def self.after_process_record (row: , result: , batch_id: )
    @batch_success = "#{batch_id}:success"
    @batch_error = "#{batch_id}:error"  	
    REDIS_BATCHES.rpush(@batch_success, row.to_json) if result == 'success'
    REDIS_BATCHES.rpush(@batch_error, row.to_json) if result == 'error'
    REDIS_BATCHES.decr(@batch_counter)
    # => check if batch_size is 0, last job completed
    after_batch if REDIS_BATCHES.get(@batch_counter).to_i <= 0
  end

  def self.after_batch
    timestamp = Time.at(@batch_id).strftime("%Y_%m_%d_%H_%M_%S")
    @output_file = "tmp/#{timestamp}.xlsx"
    package = Axlsx::Package.new
    error_sheet = package.workbook.add_worksheet(name: 'error')
    error_sheet.add_row ['error'] + @header
    success_sheet = package.workbook.add_worksheet(name: 'success')
    success_sheet.add_row @header
    package.serialize (@output_file)

    # => process success queue
    REDIS_BATCHES.lrange(@batch_success, 0, -1).each { |record| success_sheet.add_row(JSON.parse(record)) }
    # => process error queue
    REDIS_BATCHES.lrange(@batch_error, 0, -1).each { |record| error_sheet.add_row(JSON.parse(record)) }

    package.serialize (@output_file)
    cleanup_batch
  rescue => e
    Rails.logger.upload.error e
  end

  # sends results to the batch owner and removes records from redis
  def self.cleanup_batch
    # => email the results to the user who uploaded the spreadsheet
    msg = "#{REDIS.llen(@batch_success)} success, #{REDIS.llen(@batch_error)} errors"
    AmploMailer.internal_notification("Upload results", msg, @output_file, @current_user)
    Rails.logger.upload.info "finished #{@batch_id} for #{@current_user.try(:slug)} -- #{msg}"
    # => set expiration for batch keys
    [@batch_counter, @batch_size, @batch_owner, @batch_success, @batch_error].each do |key|
	    REDIS_BATCHES.expire(key, 1.week)
    end
  end

private

	# choose which spreadsheet file format is being used
	def open_spreadsheet
		case File.extname(@file.original_filename).downcase
		when '.xlsx'
			Roo::Excelx.new(@file.path, packed: nil, file_warning: :ignore)
		when '.csv'
			Roo::CSV.new(@file.path, packed: nil, file_warning: :ignore)
		else
  			#raise "Unknown file type: #{@file.original_filename}"
			Rails.logger.error "Unknown file type: #{@file.original_filename}"
			return false
		end
	end

	def setup_batch_params batch_size, header
		REDIS_BATCHES.set("#{@batch_id}:owner_id", 	@batch_owner.id)
		REDIS_BATCHES.set("#{@batch_id}:header", 	header)
		REDIS_BATCHES.set("#{@batch_id}:size", 		batch_size) # total size
		REDIS_BATCHES.set("#{@batch_id}:counter", 	batch_size) # decremented by each job
	end
end