class AddConcentrationToSpell < ActiveRecord::Migration
  def change
    add_column :spells, :concentration, :boolean
  end
end
