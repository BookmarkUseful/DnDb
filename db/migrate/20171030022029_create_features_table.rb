class CreateFeaturesTable < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.string :name
      t.text   :description
      t.string :type
      t.integer :provider_id
      t.integer :level, :limit => 1
      t.timestamps null: false
    end
  end
end
