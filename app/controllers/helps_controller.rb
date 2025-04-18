class HelpsController < InheritedResources::Base

    before_action :find_helps, only: [ :show, :edit, :update, :destroy]
    before_action :authenticate_adminuser!, except: [:index, :show]
  def index
    @helps = Help.all
    @headers = Header.all
    @abouts = About.all
    @services = Service.all

      @faqs = Faq.all
      @blogs = Blog.all.order('created_at DESC')
      @feedbacks = Feedback.all.order('created_at DESC')

  end
  def show
    @sections = Section.all
    @headers = Header.all
    @blogs = Blog.all.order('created_at DESC')
    @feedbacks = Feedback.all.order('created_at DESC')
    @categories = Category.includes(:sub_categories).all

  end
    private
      def find_helps
        @help = Help.friendly.find(params[:id])
      end


    def help_params
      params.require(:help).permit(:title, :sub_title, :body, :slug)
    end

end
