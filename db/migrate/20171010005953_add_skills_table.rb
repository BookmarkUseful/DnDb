class AddSkillsTable < ActiveRecord::Migration
  def change

    create_table :skills do |t|
      t.string  :name
      t.text    :description
      t.integer :ability, :limit => 1
    end

  end
end
