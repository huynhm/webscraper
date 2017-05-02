class AddPriceToCar < ActiveRecord::Migration[5.0]
  def change
    add_column :cars, :price, :string, array: true, default: []
  end
end
