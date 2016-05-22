class UserImportService

	def initialize file, batch_owner
		@file = file
		@batch_owner = batch_owner
		@batch_id = "#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}_#{@batch_owner.id}"
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
		set_batch_params num_rows - 1, header
		(2..num_rows).each do |i|
			row = upload_spreadsheet.row(i)
			UserImportJob.perform_later(row, @batch_id)
		end
		return 'user import process began'
	rescue => e
		Rails.logger.error "#{self.class.name}#{__method__} - #{e}"
		return e
	end

	# called after processing each record in batch
	def self.after_process_record (row: , result: , batch_id: )
		@batch_id = batch_id
		@batch_counter =  "#{@batch_id}:counter"    
		@batch_success = "#{@batch_id}:success"
		@batch_error = "#{@batch_id}:error"  	
		@batch_owner =  "#{@batch_id}:owner"  	
		@batch_header = "#{@batch_id}:header"
		REDIS_BATCHES.rpush(@batch_success, row.to_json) if result == 'success'
		REDIS_BATCHES.rpush(@batch_error, row.to_json) if result == 'error'
		REDIS_BATCHES.decr(@batch_counter)
		after_complete_batch
	rescue => e
		Rails.logger.error "#{self.name}.#{__method__} - #{e}"
	end

	# => check if batch_size is 0, last job completed
	def self.after_complete_batch
		return if REDIS_BATCHES.get(@batch_counter).to_i <= 0  	

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
		REDIS_BATCHES.lrange(@batch_error, 0, -1).each	 { |record| error_sheet.add_row(JSON.parse(record)) }

		# => send file to batch owner
		package.serialize (@output_file)
		msg = "#{REDIS_BATCHES.llen(@batch_success)} success, #{REDIS_BATCHES.llen(@batch_error)} errors"

		# => set expiration for batch keys
		[@batch_counter, @batch_size, @batch_owner, @batch_success, @batch_error, @batch_header].each do |key|
			REDIS_BATCHES.expire(key, 1.week)
		end    
	rescue => e
		Rails.logger.error "#{self.name}.#{__method__} - #{e}"
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

	def set_batch_params batch_size, header
		REDIS_BATCHES.set("#{@batch_id}:owner", 	@batch_owner)
		REDIS_BATCHES.set("#{@batch_id}:header", 	header)
		REDIS_BATCHES.set("#{@batch_id}:size", 		batch_size) # total size
		REDIS_BATCHES.set("#{@batch_id}:counter", 	batch_size) # decremented by each job
	end

end