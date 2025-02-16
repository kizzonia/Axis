ActiveAdmin.register Header do
  menu label: "Headers", parent: "Settings"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :abouts_title, :abouts_sub_title, :services_title, :services_sub_title, :boards_title, :boards_sub_title, :features_title, :features_sub_title, :feedbacks_title, :feedbacks_sub_title, :blogs_title, :blogs_sub_title, :cta1, :cta2, :headerimg, :products_title, :products_sub_title
  #
  # or
  #
  # permit_params do
  #   permitted = [:abouts_title, :abouts_sub_title, :services_title, :services_sub_title, :boards_title, :boards_sub_title, :features_title, :features_sub_title, :feedbacks_title, :feedbacks_sub_title, :blogs_title, :blogs_sub_title, :cta1, :cta2, :headerimg, :products_title, :products_sub_title]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
