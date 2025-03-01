ActiveAdmin.register SubCategory do
  menu label: "SubCategories", parent: "Store", priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
permit_params :name, :category_id, :title, :slug
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :category_id, :title, :slug]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      f.input :category_id, :label => 'Category', :as => :select, :collection => Category.all.map{|u| ["#{u.name}", u.id]}

      f.input :name
      f.input :title
    end
  end

  controller do
         def find_resource
           scoped_collection.friendly.find(params[:id])
         end
       end
end
