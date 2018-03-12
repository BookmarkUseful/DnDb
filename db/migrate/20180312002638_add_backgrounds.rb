class AddBackgrounds < ActiveRecord::Migration
  def change

    create_table :backgrounds do |t|
      t.string  :name
      t.string  :slug, unique: true
      t.text    :description
      t.string  :feature_name
      t.text    :feature_description
      t.text    :tool_proficiencies, default: '[]'
      t.text    :equipment, default: '[]'
      t.timestamps null: false
    end

    add_reference :backgrounds, :source, index: true, foreign_key: true

    create_join_table :skills, :backgrounds do |t|
      t.index [:skill_id, :background_id]
    end

  end
end
