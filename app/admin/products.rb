ActiveAdmin.register Product do
  menu label: "Products", parent: "Store", priority: 2

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
   permit_params :name, :title, :description,
   :price, :prodimage, :status, :category_id,
   :sub_category_id, :user_id
  #
  # or
  #
  # permit_params do
  #   permitted = [:name, :title, :description, :price, :prodimage, :status, :category_id, :sub_category_id, :user_id]
  #   permitted << :other if params[:action] == 'create' && current_user.admin?
  #   permitted
  # end
  form do |f|
    f.inputs do
      para "Product Belongings"
      f.input :user_id, :label => 'Users', :as => :select, :collection => User.all.map{|u| ["#{u.email}", u.id]}
      f.input :category_id, :label => 'Category', :as => :select, :collection => Category.all.map{|u| ["#{u.name}", u.id]}
      f.input :sub_category_id, :label => 'SubCategory', :as => :select, :collection => SubCategory.all.map{|u| ["#{u.name}", u.id]}

    para "Product Image"
    f.input :prodimage, as: :file

      para "Products description"
      f.input :name, label: "Product Name"
      f.input :title, label: "Product Title"
      f.input :price, label: "Product Price"
      f.input :description, as: :quill_editor
      f.input :status

    end
  end

  controller do
         def find_resource
           scoped_collection.friendly.find(params[:id])
         end
       end
end
