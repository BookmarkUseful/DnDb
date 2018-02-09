class AddTimestampsToTables < ActiveRecord::Migration
  def change
    change_table :subclasses do |t|
      t.timestamps
    end
    change_table :feats do |t|
      t.timestamps
    end
    change_table :skills do |t|
      t.timestamps
    end
  end
end
