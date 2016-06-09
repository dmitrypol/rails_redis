class Common

	# choose which spreadsheet file format is being used
	def self.open_spreadsheet file
		case File.extname(file.original_filename).downcase
		when '.xlsx'
			Roo::Excelx.new(file.path, packed: nil, file_warning: :ignore)
		when '.csv'
			Roo::CSV.new(file.path, packed: nil, file_warning: :ignore)
		else
			#raise "Unknown file type: #{@file.original_filename}"
			Rails.logger.error "Unknown file type: #{file.original_filename}"
			return false
		end
	end

  def self.save_file_to_s3 file
    # => save file to S3    https://ruby.awsblog.com/post/Tx1K43Z7KXHM5D5/Uploading-Files-to-Amazon-S3
    s3 = Aws::S3::Resource.new(client: AWS_S3_CLIENT)
    obj_key = "batch_uploads/#{Time.now.to_i}_#{file.original_filename.delete(' ')}"
    obj = s3.bucket(Rails.application.config.aws_s3_bucket).object(obj_key)
    obj.upload_file(file.path)
    Rails.logger.info "uploaded #{obj_key} #{obj.public_url} to S3"
    return obj_key
  rescue => e
    Rails.logger.error "#{self.class.name}.#{__method__} - #{e}"
  end

end