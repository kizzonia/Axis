class AccountsController < InheritedResources::Base

  private

    def account_params
      params.require(:account).permit(:balance, :slug, :revenue, :status, :verify, :user_id)
    end

end
