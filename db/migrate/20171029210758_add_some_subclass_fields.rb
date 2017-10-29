class AddSomeSubclassFields < ActiveRecord::Migration
  def change
    add_reference :class_features, :subclass, :index => true
    add_column :character_classes, :subclass_descriptor, :string
    add_column :subclasses, :description, :text
    add_reference :subclasses, :source, :index => true
  end
end
