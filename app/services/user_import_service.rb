class UserImportService

	def initialize file, batch_owner
		@file = file
		@batch_owner_id = batch_owner.id
		@batch_id = "#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}_#{@batch_owner_id}"
		@upload_spreadsheet = Common.open_spreadsheet @file
	end

	def perform
		return 'Must provide file' if @file.blank?
		return 'File must be XLSX or CSV format' if @upload_spreadsheet == false
		# => check file size
		num_rows = @upload_spreadsheet.last_row
		max_rows = 1000000
		return "Too many rows, max size is #{max_rows}" if num_rows > max_rows

		Common.save_file_to_s3 @file
		process_file num_rows

		return "user import process began - #{@file.original_filename}"
	rescue => e
		Rails.logger.error "#{self.class.name}.#{__method__} - #{e}"
		return e
	end

private

	def process_file num_rows
		header = @upload_spreadsheet.row(1)
		set_batch_params num_rows - 1, header
		(2..num_rows).each do |i|
			row = @upload_spreadsheet.row(i)
			ui_job = UserImportJob.perform_later(row, @batch_id)
		end
	end

	def set_batch_params batch_size, header
		REDIS_BATCHES.set("#{@batch_id}:header", 	header)
		REDIS_BATCHES.set("#{@batch_id}:owner_id", 	@batch_owner_id)
		REDIS_BATCHES.set("#{@batch_id}:size", 		batch_size) # total size
		REDIS_BATCHES.set("#{@batch_id}:counter", batch_size) # decremented by each job
	end

end