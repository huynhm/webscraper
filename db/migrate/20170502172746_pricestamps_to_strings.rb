class PricestampsToStrings < ActiveRecord::Migration[5.0]
  def self.up
    change_table :cars do |t|
      t.change :pricestamps, :string, array: true, default: []
    end
  end
  def self.down
    change_table :cars do |t|
      t.change :pricestamps, :datetime
    end
  end
end



