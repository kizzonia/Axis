class BannersController < InheritedResources::Base

  private

    def banner_params
      params.require(:banner).permit(:title, :sub_title, :bannerimg, :slug)
    end

end
