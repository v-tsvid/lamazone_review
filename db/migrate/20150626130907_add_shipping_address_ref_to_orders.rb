class AddShippingAddressRefToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :shipping_id, :integer
  end
end
