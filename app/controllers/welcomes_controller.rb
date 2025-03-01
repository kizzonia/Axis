class WelcomesController < InheritedResources::Base
  before_action :authenticate_adminuser!, except: [:index, :show]

  def index
    @welcomes = Welcome.all
    @headers = Header.all
    @abouts = About.all.order('created_at ASC')
    @services = Service.all.order('created_at ASC')
    @faqs = Faq.all.order('created_at ASC')
    @blogs = Blog.all.order('created_at DESC')
    @feedbacks = Feedback.all.order('created_at DESC')
    @features = Feature.all.order('created_at ASC')
    @banners = Banner.all.order('created_at ASC')

    @categories = Category.includes(:sub_categories).all
    if params[:search].present?
      @products = Product.where('name LIKE ? OR description LIKE ?', "%#{params[:search]}%", "%#{params[:search]}%")
    else
      @products = []
    end
    @products = Product.includes(:category, :sub_category, :user).all

  end

  private


    def welcome_params
      params.require(:welcome).permit(:title, :logoimg, :desc, :whatsapp, :ig, :ln, :section, :link, :footer, :phone, :address, :twitter, :email, :youtube, :telegram)
    end

end
