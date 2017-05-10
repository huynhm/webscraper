class AddEdmundsToPricehistory < ActiveRecord::Migration[5.0]
  def change
    add_column :pricehistories, :edmunds, :string
  end
end
