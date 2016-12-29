class AddRarityToItems < ActiveRecord::Migration
  def change
    add_column :items, :rarity, :integer, :default => 0
  end
end
