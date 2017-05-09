class AddCargurusCarsdotcomToCars < ActiveRecord::Migration[5.0]
  def change
    add_column :cars, :carsdotcom, :string
    add_column :cars, :cargurus, :string
  end
end
