ActiveAdmin.register Header do
  menu label: "Headers", parent: "Settings"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :abouts_title, :abouts_sub_title,
  :services_title, :services_sub_title, :boards_title,
  :boards_sub_title, :features_title, :features_sub_title,
  :feedbacks_title, :feedbacks_sub_title, :blogs_title,
  :blogs_sub_title, :cta1, :cta2, :headerimg, :products_title,
   :products_sub_title
  #
  # or
  #
  # permit_params do
  #   permitted = [:abouts_title, :abouts_sub_title, :services_title, :services_sub_title, :boards_title, :boards_sub_title, :features_title, :features_sub_title, :feedbacks_title, :feedbacks_sub_title, :blogs_title, :blogs_sub_title, :cta1, :cta2, :headerimg, :products_title, :products_sub_title]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form(:html => { :multipart => true }) do |f|
    f.inputs do


      para "headerimg"
      # f.input :headerimg, as: :file


      para "abouts/who we are"
      f.input :abouts_title, placeholder: "About Us Header Title"
      f.input :abouts_sub_title
      # f.input :abtsectionimg, as: :file

      para "Services"

      f.input :services_title
      f.input :services_sub_title

      # para "Plans/Account Types/packages"
      # f.input :plansimg, as: :file
      # f.input :plans_title
      # f.input :plans_sub_title
      # f.input :planscta1
      # f.input :planscta2



      para "features"
      # f.input :featheaderimg, as: :file
      f.input :features_title
      f.input :features_sub_title

      para "Feedback"

      f.input :feedbacks_title
      f.input :feedbacks_sub_title


      para "projects/events"

      f.input :projects_title, placeholder: "Branches  Board header"
      f.input :projects_sub_title


      para "blog"

      f.input :blogs_title
      f.input :blogs_sub_title


      para "AGent"
      f.input :boards_title, placeholder: "Teams/Agent/Board header"
      f.input :boards_sub_title

      para "call to action-1"
      f.input :cta1
      f.input :cta2


    end
    f.actions
  end
end
