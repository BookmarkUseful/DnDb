class ExpandingOnClasses < ActiveRecord::Migration
  def change
    add_column :character_classes, :hit_die,       :integer, :limit => 1
    add_column :character_classes, :saving_throws, :string
    add_column :character_classes, :spell_slots,   :string # serialized hash
    add_column :character_classes, :spell_ability, :integer, :limit => 1

    create_table :class_features do |t|
      t.string  :name
      t.text    :description
      t.integer :level, :limit => 1
      t.integer :character_class_id, :null => false, :references => [:character_classes, :id]
    end

    create_table :subclasses do |t|
      t.string  :name
      t.integer :character_class_id, :null => false, :references => [:character_classes, :id]
    end

  end
end
