class RemovePriceFromCar < ActiveRecord::Migration[5.0]
  def change
    remove_column :cars, :price, :string
  end
end
