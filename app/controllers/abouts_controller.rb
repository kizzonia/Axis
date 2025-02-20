class AboutsController < InheritedResources::Base

  before_action :find_abouts, only: [ :show, :edit, :update, :destroy]
  before_action :authenticate_adminuser!, except: [:index, :show]
  def index
    @abouts = About.all
    @headers = Header.all

  end

  def show
    @abouts = About.all
    @services = Service.all

      @headers = Header.all
      @blogs = Blog.all.order('created_at DESC')
      @feedbacks = Feedback.all.order('created_at DESC')

  end

  private
  def find_abouts
    @about = About.friendly.find(params[:id])
  end
    def about_params
      params.require(:about).permit(:title, :sub_title, :body, :abtimg, :slug, :icon)
    end

end
