class AddAbbreviationToSource < ActiveRecord::Migration
  def change
    add_column :sources, :abbreviation, :string
  end
end
