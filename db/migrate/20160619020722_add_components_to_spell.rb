class AddComponentsToSpell < ActiveRecord::Migration
  def change
    add_column :spells, :components, :text
  end
end
