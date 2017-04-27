class AddOldPricesArrayToCars < ActiveRecord::Migration[5.0]
  def change
    add_column :cars, :oldprices, :string, array: true, default: []
    add_column :cars, :pricestamps, :datetime, array: true, default: []
  end
end
