class AddSourceToSpells < ActiveRecord::Migration
  def change
    add_reference :spells, :source, index: true, foreign_key: true
  end
end
