class AddSlugsToAllModels < ActiveRecord::Migration
  def change
  	add_column :character_classes, :slug, :string, unique: true
  	add_column :skills, :slug, :string, unique: true
  	add_column :features, :slug, :string, unique: true
  	add_column :subclasses, :slug, :string, unique: true
  	add_column :spells, :slug, :string, unique: true
  	add_column :sources, :slug, :string, unique: true
  	add_column :feats, :slug, :string, unique: true
  	add_column :authors, :slug, :string, unique: true
  end
end
