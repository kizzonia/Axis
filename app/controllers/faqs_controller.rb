class FaqsController < InheritedResources::Base

  private

    def faq_params
      params.require(:faq).permit(:title, :icon, :body, :slug)
    end

end
