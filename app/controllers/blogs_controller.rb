class BlogsController < InheritedResources::Base

  before_action :find_blogs, only: [ :show, :edit, :update, :destroy]
  before_action :authenticate_adminuser!, except: [:index, :show]
def index
  @blogs = Blog.all
  @headers = Header.all

end
def show
  @sections = Section.all
  @headers = Header.all
  @blogs = Blog.all.order('created_at DESC')
  @feedbacks = Feedback.all.order('created_at DESC')

end
  private
    def find_blogs
      @blog = Blog.friendly.find(params[:id])
    end


    def blog_params
      params.require(:blog).permit(:title, :sub_title, :body, :blogimg, :videolink, :blogvideoimg, :slug)
    end

end
