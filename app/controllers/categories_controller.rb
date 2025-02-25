class CategoriesController < InheritedResources::Base

  private

    def category_params
      params.require(:category).permit(:title, :cateimg, :slug, :name, :sub_title)
    end

end
