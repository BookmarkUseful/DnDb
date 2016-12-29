class AddIndexedToSources < ActiveRecord::Migration
  def change
    add_column :sources, :indexed, :boolean
  end
end
