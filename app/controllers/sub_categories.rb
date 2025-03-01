class SubCategoriesController < InheritedResources::Base
  before_action :find_sub_categories, only: [ :show, :edit, :update, :destroy]
  before_action :authenticate_adminuser!, except: [:index, :show]
  def index
    @abouts = About.all
    @headers = Header.all
    @categories = Category.includes(:sub_categories).all

    if params[:search].present?
      @products = Product.where('name LIKE ? OR description LIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")
    else
      @products = []
    end

  end

  def show
    @abouts = About.all
    @services = Service.all

      @headers = Header.all
      @blogs = Blog.all.order('created_at DESC')
      @feedbacks = Feedback.all.order('created_at DESC')

  end

  private
  def find_sub_categories
    @sub_category = SubCategory.friendly.find(params[:id])
  end
    def category_params
      params.require(:sub_category).permit(:title, :slug, :name)
    end

end
