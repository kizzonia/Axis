ActiveAdmin.register Help do
  menu label: "Help", parent: "Pages"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :sub_title, :body, :slug
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :sub_title, :body, :slug]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
