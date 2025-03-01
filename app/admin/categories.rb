ActiveAdmin.register Category do
menu label: "Categories", parent: "Store", priority: 1
  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :cateimg, :slug, :name, :sub_title, :icon, :iconimg
  #
  # or
  #
  # permit_params do
  #   permitted = [:title, :cateimg, :slug, :name, :sub_title]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form(:html => { :multipart => true }) do |f|
    f.inputs do
      f.input :title
        f.input :name
        f.input :icon
      f.input :iconimg, as: :file
      f.input :cateimg, as: :file, label: "Main Img"
      f.input :sub_title, placeholder: "description"

    end
    f.actions
  end

  # controller do
  #        def find_resource
  #          scoped_collection.friendly.find(params[:id])
  #        end
  #      end
end
