class AddFeatsTable < ActiveRecord::Migration
  def change

    create_table :feats do |t|
      t.string  :name
      t.text    :description
      t.string  :prerequisite
      t.index   :source_id
    end

  end
end
