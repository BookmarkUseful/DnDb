class DropPermalinkColumns < ActiveRecord::Migration
  def change
  	remove_column :authors, :permalink
  	remove_column :items, :permalink
  end
end
