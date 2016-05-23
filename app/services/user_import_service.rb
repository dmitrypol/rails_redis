class UserImportService

	def initialize file, batch_owner
		@file = file
		@batch_owner_id = batch_owner.id
		@batch_id = "#{Time.now.strftime("%Y-%m-%d-%H-%M-%S")}_#{@batch_owner_id}"
	end

	def perform
		return 'Must provide file' if @file.blank?
		upload_spreadsheet = open_spreadsheet
		return 'File must be XLSX or CSV format' if upload_spreadsheet == false
		# => check file size
		num_rows = upload_spreadsheet.last_row
		max_rows = 1000000
		return "Too many rows, max size is #{max_rows}" if num_rows > max_rows

		header = upload_spreadsheet.row(1)
		set_batch_params num_rows - 1, header
		(2..num_rows).each do |i|
			row = upload_spreadsheet.row(i)
			ui_job = UserImportJob.perform_later(row, @batch_id)
		end
		return 'user import process began'
	rescue => e
		Rails.logger.error "#{self.class.name}#{__method__} - #{e}"
		return e
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
		REDIS_BATCHES.set("#{@batch_id}:header", 	header)
		REDIS_BATCHES.set("#{@batch_id}:owner_id", 	@batch_owner_id)
		REDIS_BATCHES.set("#{@batch_id}:size", 		batch_size) # total size
		REDIS_BATCHES.set("#{@batch_id}:counter", batch_size) # decremented by each job
	end

end