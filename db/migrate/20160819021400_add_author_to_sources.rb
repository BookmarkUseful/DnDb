class AddAuthorToSources < ActiveRecord::Migration
  def change
    add_reference :sources, :author, index: true, foreign_key: true
  end
end
