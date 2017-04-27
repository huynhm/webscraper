class ChangeCarColumns < ActiveRecord::Migration[5.0]
  def change
  	add_column :cars, :vin, :string
  	add_column :cars, :make, :string
  	add_column :cars, :model, :string
  	add_column :cars, :year, :string
  	add_column :cars, :price, :string
  	remove_column :cars, :title
  	remove_column :cars, :description
  end
end
