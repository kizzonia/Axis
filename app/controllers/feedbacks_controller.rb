class FeedbacksController < InheritedResources::Base
  before_action :find_feedbacks, only: [ :show, :edit, :update, :destroy]
  before_action :authenticate_adminuser!, except: [:index, :show]
  def index
    @feedbacks = Feedback.all.order('created_at DESC')
  end

  def show
  end

  private
  def find_feedbacks
    @feedback = Feedback.find(params[:id])
  end

    def feedback_params
      params.require(:feedback).permit(:title, :icon, :body, :slug)
    end

end
