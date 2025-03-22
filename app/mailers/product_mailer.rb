class ProductMailer < ApplicationMailer
  default :from => "support@theaxismarket.com"
  def product_email(user, product)
    @user = user
    @product = product
     mail(to: user.email, subject: 'Product Upload')
  end
end
