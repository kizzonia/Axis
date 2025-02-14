class BlogsController < InheritedResources::Base

  private

    def blog_params
      params.require(:blog).permit(:title, :sub_title, :body, :blogimg, :videolink, :blogvideoimg, :slug)
    end

end
