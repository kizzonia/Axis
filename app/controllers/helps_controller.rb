class HelpsController < InheritedResources::Base

  private

    def help_params
      params.require(:help).permit(:title, :sub_title, :body, :slug)
    end

end
