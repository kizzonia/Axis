class ServicesController < InheritedResources::Base

  private

    def service_params
      params.require(:service).permit(:title, :slug, :icon, :sub_title, :body, :serviceimg)
    end

end
