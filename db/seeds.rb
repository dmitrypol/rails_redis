# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

github_logins = ['dhh', 'antirez', 'matz', 'tenderlovej', 'josevalim', 'wycats', 'schneems', 'smartinez87', 'durran', 'mperham']
User.delete_all
10.times do |i|
	User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, zipcode: Faker::Address.zip, github_login: github_logins[i] )
end