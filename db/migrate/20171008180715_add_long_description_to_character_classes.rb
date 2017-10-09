class AddLongDescriptionToCharacterClasses < ActiveRecord::Migration
  def change
    add_column :character_classes,  :long_description, :text
  end
end
