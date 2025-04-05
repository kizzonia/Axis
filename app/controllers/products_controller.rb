class ProductsController < InheritedResources::Base
  layout :resolve_layout
  before_action :authenticate_user!, except: [:show]
  add_flash_types :success, :danger, :info, :notice
  before_action :find_product, only: [:show, :edit, :update, :destroy]

  def index
    @accounts = Account.where(user_id: current_user).order('created_at ASC')
    @products = current_user.products.includes(:category, :sub_category, :images).order('created_at ASC')
    @wallets = Wallet.where(user_id: current_user).order('created_at ASC')
  end

  def show
    @wallets = Wallet.where(user_id: current_user).order('created_at ASC')
    @headers = Header.all
    @blogs = Blog.all.order('created_at DESC')
    @feedbacks = Feedback.all.order('created_at DESC')
    @categories = Category.includes(:sub_categories).all
  end

  def new
    @categories = Category.includes(:sub_categories).all
    @product = current_user.products.new
    @product.images.build # Initialize empty image for the form
  end

  def create
    @product = current_user.products.new(product_params)

    if @product.save
      user = User.find_by_id(@product.user_id)
      product = @product
      ProductMailer.product_email(user, product).deliver_later

      redirect_to products_path, notice: 'Product was successfully created. An email has been sent to you with your product details.'
    else
      @product.images.build if @product.images.empty? # Ensure at least one image field on validation error
      render :new
    end
  end

  def edit
    @categories = Category.includes(:sub_categories).all
    @product.images.build if @product.images.empty? # Add empty image field if none exist
  end

  def update
    if @product.update(product_params)
      redirect_to products_path, notice: 'Product was successfully updated.'
    else
      @product.images.build if @product.images.empty? # Ensure image field on validation error
      render :edit
    end
  end

  def destroy
    @product.destroy
    redirect_to products_path, notice: 'Product was successfully deleted.'
  end

  private

  def resolve_layout
    case action_name
    when "new", "create", "edit", "index"
      "accounts"
    when "show"
      "application"
    else
      "application"
    end
  end

  def find_product
    @product = Product.friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :title, :description, :sku, :slug, :overview,
      :verified, :state, :feature, :discounttype, :price,
      :prodimage, :status, :category_id, :sub_category_id, :user_id,
      images_attributes: [:id, :image, :_destroy] # Permit nested image attributes
    )
  end
end
