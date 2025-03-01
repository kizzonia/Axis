class ServicesController < InheritedResources::Base


    before_action :find_services, only: [ :show, :edit, :update, :destroy]
    before_action :authenticate_adminuser!, except: [:index, :show]
    def index
      @services = Service.all.order('created_at DESC')
      @welcomes = Welcome.all
      @headers = Header.all
      @abouts = About.all.order('created_at DESC')
      @services = Service.all.order('created_at DESC')
      @faqs = Faq.all.order('created_at DESC')
      @blogs = Blog.all.order('created_at DESC')
      @feedbacks = Feedback.all.order('created_at DESC')

    end

    def show
      @headers = Header.all
      @blogs = Blog.all.order('created_at DESC')
      @feedbacks = Feedback.all.order('created_at DESC')
      @categories = Category.includes(:sub_categories).all

    end

    private
    def find_services
      @service = Service.friendly.find(params[:id])
    end
    def service_params
      params.require(:service).permit(:title, :slug, :icon, :sub_title, :body, :serviceimg)
    end

end
