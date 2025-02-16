ActiveAdmin.register Account do
  menu label: "Accounts", parent: "Users", priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  # permit_params :balance, :slug, :revenue, :status, :verify, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:balance, :slug, :revenue, :status, :verify, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
