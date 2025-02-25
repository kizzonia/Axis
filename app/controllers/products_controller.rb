class ProductsController < InheritedResources::Base

  private

    def product_params
      params.require(:product).permit(:name, :title, :description, :price, :prodimage, :status, :category_id, :sub_category_id, :user_id)
    end

end
