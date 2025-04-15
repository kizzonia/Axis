# app/mailers/order_mailer.rb
class OrderMailer < ApplicationMailer
  default from: 'support@theaxismarket.com'

  def buyer_payment_confirmation(order)
    @order = order
    @user = order.user
    mail(
      to: @user.email,
      subject: "Payment Confirmation for Order ##{@order.id}"
    )
  end

  def seller_payment_notification(order)
    @order = order
    @seller = order.seller
    mail(
      to: @seller.email,
      subject: "New Sale Notification - Order ##{@order.id}"
    )
  end
end
