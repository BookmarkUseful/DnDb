class AddNumStartingSkillsToCharacterClass < ActiveRecord::Migration
  def change
    add_column :character_classes,  :num_starting_skills, :integer
  end
end
