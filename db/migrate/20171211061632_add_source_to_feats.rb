class AddSourceToFeats < ActiveRecord::Migration
  def change
    remove_column :feats, :source_id
    add_reference :feats, :source, index: true, foreign_key: true
  end
end
