# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Article.delete_all
User.delete_all

github_logins = ['dhh', 'antirez', 'matz', 'tenderlove', 'josevalim', 'wycats', 'schneems', 'smartinez87', 'durran', 'mperham']
10.times do |i|
	User.new(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, zipcode: Faker::Address.zip, github_login: github_logins[i] ).save!
end

30.times do |i|
	Article.new(title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, user: User.all.sample).save!
end

# => generate stats in redis-objects
1000.times do |i|
	ArticleDailyViewsJob.perform_now(Article.all.sample, Time.now - rand(0..1000000))
end