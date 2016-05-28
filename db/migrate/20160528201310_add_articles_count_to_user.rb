class AddArticlesCountToUser < ActiveRecord::Migration
  def change
  	add_column :users, :articles_count, :integer
  end
end
