class QueueUserImportJob < ApplicationJob
  queue_as :default

  def perform(file_s3_object_key, filename, batch_id)
  	# => grab file from S3 		http://ruby.awsblog.com/post/Tx354Y6VTZ421PJ/-Downloading-Objects-from-Amazon-span-class-matches-S3-span-using-the-AWS-SDK-fo
		#s3_file = AWS_S3_CLIENT.get_object(bucket: Rails.application.config.aws_s3_bucket, key: file_s3_object_key)
		s3_file = File.open("public/#{filename}", 'wb')
		AWS_S3_CLIENT.get_object({ bucket: Rails.application.config.aws_s3_bucket, key: file_s3_object_key }, target: s3_file)

  	# => check counter which row in the file we should process

  	process_file s3_file, batch_id
  	Rails.logger.info "queueing records #{file_s3_object_key} for #{batch_id}"
  end

private

	def process_file file, batch_id
		upload_spreadsheet = Common.open_spreadsheet file
		header = upload_spreadsheet.row(1)
		UserImportService.set_batch_params num_rows - 1, header
		(2..num_rows).each do |i|
			row = upload_spreadsheet.row(i)
			ui_job = UserImportJob.perform_later(row, batch_id)
			# => increment spreadsheet row counter in Redis
		end
	end

end
