class WelcomesController < InheritedResources::Base

  private

    def welcome_params
      params.require(:welcome).permit(:title, :logoimg, :desc, :whatsapp, :ig, :ln, :section, :link, :footer, :phone, :address, :twitter, :email, :youtube, :telegram)
    end

end
