class AddLinkColumnToSource < ActiveRecord::Migration
  def change
    add_column :sources, :link, :string
  end
end
