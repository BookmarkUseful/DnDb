class AddParentSchoolToSpell < ActiveRecord::Migration
  def change
    add_column :spells, :parent_school, :integer
  end
end
