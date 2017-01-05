class AddDescriptionToCharacterClass < ActiveRecord::Migration
  def change
    add_column :character_classes, :description, :text
  end
end
