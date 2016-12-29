class AddSourceIdToCharacterClasses < ActiveRecord::Migration
  def change
    add_reference :character_classes, :source, index: true, foreign_key: true
  end
end
