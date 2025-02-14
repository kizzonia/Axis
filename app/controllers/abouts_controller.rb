class AboutsController < InheritedResources::Base

  private

    def about_params
      params.require(:about).permit(:title, :sub_title, :body, :abtimg, :slug)
    end

end
