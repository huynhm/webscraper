class AddUrLsToCars < ActiveRecord::Migration[5.0]
  def change
    add_column :cars, :urls, :string, array: true, default: []
  end
end
