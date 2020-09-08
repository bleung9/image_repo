class AddIdhashToImage < ActiveRecord::Migration[6.0]
  def change
    add_column :images, :idhash, :string
  end
end
