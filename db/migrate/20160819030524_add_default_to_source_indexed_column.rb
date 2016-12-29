class AddDefaultToSourceIndexedColumn < ActiveRecord::Migration
  def up
    change_column :sources, :indexed, :boolean, :default => false
  end

  def down
    change_column :sources, :indexed, :boolean, :default => nil
  end
end
