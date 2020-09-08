class AddTextToImage < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :text, :string
  end
end
