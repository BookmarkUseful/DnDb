class CreateCharacterClassesSpellsJoinTable < ActiveRecord::Migration
  def change

    create_join_table :character_classes, :spells

    add_index :character_classes, :name, :unique => true
    add_index :spells, :name, :unique => true

  end
end
