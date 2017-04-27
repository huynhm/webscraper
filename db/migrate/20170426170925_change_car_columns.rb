
class CreateCars < ActiveRecord::Migration[5.0]
  def change
    create_table :cars do |t|
      t.string :user
      t.string :password
	  	t.string :vin
	  	t.string :make
	  	t.string :model
	  	t.string :year
	  	t.string :price

      t.timestamps
    end
  end
end
