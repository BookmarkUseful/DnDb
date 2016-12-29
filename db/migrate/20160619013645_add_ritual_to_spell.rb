class AddRitualToSpell < ActiveRecord::Migration
  def change
    add_column :spells, :ritual, :boolean
  end
end
