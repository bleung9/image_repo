class CreateImages < ActiveRecord::Migration[6.0]
  def change
    create_table :images do |t|
      t.string :image
      t.integer :width
      t.integer :height

      t.timestamps
    end
  end
end
