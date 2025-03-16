ActiveAdmin.register Order do
  menu label: "Orders", parent: "Store", priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :user_id, :total_price, :status, :first_name, :last_name, :state, :city, :country, :street_address, :phone, :email, :zip_code, :order_note, :seller_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:user_id, :total_price, :status, :first_name, :last_name, :state, :city, :country, :street_address, :phone, :email, :zip_code, :order_note, :seller_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
