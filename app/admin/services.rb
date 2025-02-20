ActiveAdmin.register Service do
  menu label: "Services", parent: "Pages"

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :slug, :icon, :sub_title, :body, :serviceimg
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :slug, :icon, :sub_title, :body, :serviceimg]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form(:html => { :multipart => true }) do |f|
    f.inputs do
      f.input :serviceimg
      f.input :title
      f.input :sub_title, placeholder: "description"
      f.input :body,  as: :quill_editor
    end
    f.actions
  end

  controller do
         def find_resource
           scoped_collection.friendly.find(params[:id])
         end
       end
end
