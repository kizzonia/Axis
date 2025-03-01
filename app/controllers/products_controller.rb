class ProductsController < InheritedResources::Base
  layout "accounts"
  before_action :authenticate_user!
  add_flash_types :success, :danger, :info, :notice

  before_action :find_product, only: [ :show, :edit, :update, :destroy]


def index
    @accounts = Account.where(user_id: current_user).order('created_at ASC')
    @products = Product.where(user_id: current_user).order('created_at ASC')
    @products = current_user.products.includes(:category, :sub_category)

end
   def new
     @product = current_user.products.new
   end

   def create
     @product = current_user.products.new(product_params)
     if @product.save
       user = User.find_by_id(@account.user_id)
      product = @product
       ProductMailer.product_email(user, product).deliver_later

       redirect_to products_path, notice: 'Product was successfully created.'
     else
       render :new
     end
   end

   def edit
     @product = current_user.products.find(params[:id])
   end

   def update
     @product = current_user.products.find(params[:id])
     if @product.update(product_params)
       redirect_to products_path, notice: 'Product was successfully updated.'
     else
       render :edit
     end
   end

   def destroy
     @product = current_user.products.find(params[:id])
     @product.destroy
     redirect_to products_path, notice: 'Product was successfully deleted.'
   end

  private
  def find_product
    @product = Product.find(params[:id])
  end

    def product_params
      params.require(:product).permit(:name, :title, :description, :sku, :state, :feature, :discounttype, :price, :prodimage, :status, :category_id, :sub_category_id, :user_id)
    end

end
