ActiveAdmin.register Welcome do
  menu label: "Welcomes", parent: "Settings"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :logoimg, :desc, :whatsapp, :ig, :ln, :section, :link, :footer, :phone, :address, :twitter, :email, :youtube, :telegram
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :logoimg, :desc, :whatsapp, :ig, :ln, :section, :link, :footer, :phone, :address, :twitter, :email, :youtube, :telegram]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end

end
