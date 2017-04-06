class Spells < ActiveRecord::Migration
  def change
    add_column :spells, :source_name, :string
  end
end
