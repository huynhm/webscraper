class CreateOldPrices < ActiveRecord::Migration[5.0]
  def change
    create_table :old_prices do |t|
      t.string :vin
      t.string :oldprice

      t.timestamps
    end
  end
end
