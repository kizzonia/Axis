class SupportsController < InheritedResources::Base

  private

    def support_params
      params.require(:support).permit(:title, :sub_title, :body, :help_id)
    end

end
