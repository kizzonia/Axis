class SubCategoriesController < ApplicationController

  before_action :find_SubCategory, only: [ :show, :edit, :update, :destroy]
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
    @products = Product.includes(:category, :sub_category, :user).all

      @headers = Header.all
      @blogs = Blog.all.order('created_at DESC')
      @feedbacks = Feedback.all.order('created_at DESC')

      @categories = Category.includes(:sub_categories).all
      @category = @sub_category.category
      @sub_categories = @category.sub_categories

  end

  private
  def find_SubCategory
    @sub_category = SubCategory.friendly.find(params[:id])
  end

end
