class DropClassFeaturesStandaloneTable < ActiveRecord::Migration
  def change
    drop_table :class_features
  end
end
