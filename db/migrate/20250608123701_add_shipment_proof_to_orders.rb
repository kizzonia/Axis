class AddShipmentProofToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :shipment_proof, :string
  end
end
