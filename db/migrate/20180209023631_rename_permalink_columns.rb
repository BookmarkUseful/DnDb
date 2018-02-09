class RenamePermalinkColumns < ActiveRecord::Migration
  def change
    remove_column :spells, :permalink
    remove_column :character_classes, :permalink
    remove_column :sources, :permalink
    remove_column :spells, :parent_school

    rename_column :character_classes, :description, :summary
    rename_column :character_classes, :long_description, :description
  end
end
