ActiveAdmin.register User do
menu label: "User Profiles", parent: "Users", priority: 2
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at
  #
  # or
  #
  # permit_params do
  #   permitted = [:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  # form(:html => { :multipart => true }) do |f|
  #   f.inputs do
  #     f.input :status
  #     f.input :verified
  #     f.input :body,  as: :quill_editor
  #   end
  #   f.actions
  # end
  def display_name
    self.email
  end
end
