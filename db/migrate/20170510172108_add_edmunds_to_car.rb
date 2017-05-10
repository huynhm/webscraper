class AddEdmundsToCar < ActiveRecord::Migration[5.0]
  def change
    add_column :cars, :edmunds, :string
  end
end
