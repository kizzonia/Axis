class FaqsController < InheritedResources::Base

  before_action :find_faqs, only: [ :show, :edit, :update, :destroy]
  before_action :authenticate_adminuser!, except: [:index, :show]
  def index
    @faqs = Faq.all.order('created_at DESC')
    @headers = Header.all

  end

  def show
  end

  private
  def find_faqs
    @faq = Faq.find(params[:id])
  end
    def faq_params
      params.require(:faq).permit(:title, :icon, :body, :slug)
    end

end
