class AddZipcodeGithubLoginToUser < ActiveRecord::Migration
  def change
    add_column :users, :zipcode, :string
    add_column :users, :github_login, :string
  end
end
