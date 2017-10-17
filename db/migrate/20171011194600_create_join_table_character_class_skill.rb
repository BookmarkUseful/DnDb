class CreateJoinTableCharacterClassSkill < ActiveRecord::Migration
  def change
    create_join_table :character_classes, :skills do |t|
      t.index :character_class_id
      t.index :skill_id
    end
  end
end
