class CreateSources < ActiveRecord::Migration
  def change
    create_table :sources do |t|
      t.string :name
      t.integer :page_count
      t.integer :kind

      t.timestamps null: false
    end
  end
end
