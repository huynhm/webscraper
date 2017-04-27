class AddCarToOldPrices < ActiveRecord::Migration[5.0]
  def change
    add_reference :old_prices, :car, foreign_key: true
  end
end
