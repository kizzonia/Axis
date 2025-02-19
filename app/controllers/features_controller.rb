class FeaturesController < InheritedResources::Base

  private

    def feature_params
      params.require(:feature).permit(:title, :sub_title, :body, :slug)
    end

end
