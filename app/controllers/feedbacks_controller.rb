class FeedbacksController < InheritedResources::Base

  private

    def feedback_params
      params.require(:feedback).permit(:title, :icon, :body, :slug)
    end

end
