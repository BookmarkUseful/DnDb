class AddPermalinkColumns < ActiveRecord::Migration
  def change
    add_column :spells,  :permalink, :string
    add_column :character_classes, :permalink, :string
    add_column :items,   :permalink, :string
    add_column :sources, :permalink, :string
    add_column :authors, :permalink, :string
  end
end
