class BannersController < InheritedResources::Base
  before_action :authenticate_adminuser!, except: [:index, :show]

  private

    def banner_params
      params.require(:banner).permit(:title, :sub_title, :bannerimg, :slug)
    end

end
