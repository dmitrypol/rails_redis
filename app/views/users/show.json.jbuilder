# creates separate keys for each record, can be busted indivdiually
json.cache! @user do
  json.extract! @user, :id, :first_name, :last_name, :email, :zipcode, :github_login, :created_at, :updated_at
end