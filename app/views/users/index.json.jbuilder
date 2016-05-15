json.array!(@users) do |user|
json.cache! user do
  # creates separate keys for each record, can be busted indivdiually
  json.extract! user, :id, :first_name, :last_name, :email, :zipcode, :github_login
  json.url user_url(user, format: :json)
end
end
