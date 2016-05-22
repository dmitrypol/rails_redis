namespace :misc do

  desc 'generate user csv file'
  task :gen_user_csv do
  	num_users = 1000
	CSV.open("tmp/user_import_#{num_users}.csv", 'wb') do |csv|
	  csv << ['first_name', 'last_name', 'email']
	  num_users.times do |i|
	  	csv << ["f#{i}", "l#{i}", "user#{i}@email.com"]
	  end
	end  	
  end

end
