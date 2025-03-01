class CategoriesController < InheritedResources::Base
  before_action :find_categories, only: [ :index, :show, :edit, :update, :destroy]
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

      @categories = Category.includes(:sub_categories).all
      @sub_categories = @category.sub_categories

     @products = @category.products
  end

  private
  def find_categories
    @category = Category.friendly.find(params[:id])
  end
    def category_params
      params.require(:category).permit(:title, :cateimg, :iconimage, :icon, :slug, :name, :sub_title)
    end

end
