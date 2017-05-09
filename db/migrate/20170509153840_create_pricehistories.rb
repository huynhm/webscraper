class CreatePricehistories < ActiveRecord::Migration[5.0]
  def change
    create_table :pricehistories do |t|
    	t.string :vin
    	t.string :carsdotcom
    	t.string :cargurus

      t.timestamps
    end
  end
end
