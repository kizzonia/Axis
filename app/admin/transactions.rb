ActiveAdmin.register Transaction do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :wallet_id, :amount, :transaction_type, :status, :reference, :payment_method, :user_id, :phone_number, :processed_at, :error_message, :description, :deposit_id, :pawapay_reference, :merchant_reference, :operation_type, :currency
  #
  # or
  #
  # permit_params do
  #   permitted = [:wallet_id, :amount, :transaction_type, :status, :reference, :payment_method, :user_id, :phone_number, :processed_at, :error_message, :description, :deposit_id, :pawapay_reference, :merchant_reference, :operation_type, :currency]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  
end
