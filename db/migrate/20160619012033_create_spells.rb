class CreateSpells < ActiveRecord::Migration
  def change
    create_table :spells do |t|
      t.string :name
      t.integer :level
      t.integer :school
      t.integer :casting_time
      t.integer :range
      t.integer :duration
      t.string :description

      t.timestamps null: false
    end
  end
end
