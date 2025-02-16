ActiveAdmin.register About do
menu label: "About", parent: "Pages", priority: 3
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :sub_title, :body, :abtimg, :slug
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :sub_title, :body, :abtimg, :slug]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
