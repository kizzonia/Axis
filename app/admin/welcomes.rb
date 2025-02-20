ActiveAdmin.register Welcome do
  menu label: "Welcomes", parent: "Settings", priority: 4
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :logoimg, :desc, :whatsapp, :ig, :ln, :section, :link, :footer, :phone, :address,
   :twitter, :email, :youtube, :telegram
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :logoimg, :desc, :whatsapp, :ig, :ln, :section, :link, :footer, :phone, :address, :twitter, :email, :youtube, :telegram]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form(:html => { :multipart => true }) do |f|
     f.inputs do
      f.input :address, placeholder: "address"
      f.input :logoimg, as: :file
      f.input :footer, label: "email", placeholder: "footer description email"
      f.input :phone, placeholder: "phone"
      f.input :title, placeholder: "Seo tilte"
      f.input :desc, placeholder: "Google Description"

      f.input :section, placeholder: "Quick Summary & SEO"

      para "Social Handles"

      f.input :whatsapp
      f.input :ig, placeholder: "Instagram"
      f.input :ln, placeholder: "facebook", label: "facebook"
      f.input :twitter, label: "Snapchat"
      f.input :youtube
      f.input :telegram




    end
    f.actions
  end
end
