class AddRacesAndSubraces < ActiveRecord::Migration
  def change

    create_table :races do |t|
      t.string :name
      t.string :slug, unique: true
      t.text   :description

      t.timestamps null: false
    end

    create_table :subraces do |t|
    	t.string :name
      t.string :slug, unique: true
    	t.text   :description

    	t.timestamps null: false
    end

    add_reference :races, :source, index: true, foreign_key: true
    add_reference :subraces, :source, index: true, foreign_key: true
    add_reference :subraces, :race, index: true, foreign_key: true

  end
end
