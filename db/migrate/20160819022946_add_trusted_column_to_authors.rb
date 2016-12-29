class AddTrustedColumnToAuthors < ActiveRecord::Migration
  def change
    add_column :authors, :trusted, :boolean
  end
end
