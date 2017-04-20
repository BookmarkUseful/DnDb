class AddSubclassFeatures < ActiveRecord::Migration
  def change

    create_table :subclass_features do |t|
      t.string  :name
      t.text    :description
      t.integer :level, :limit => 1
      t.integer :subclass_id, :null => false, :references => [:subclasses, :id]
    end

  end
end
