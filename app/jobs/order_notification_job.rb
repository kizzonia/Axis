# app/jobs/order_notification_job.rb
class OrderNotificationJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.find(order_id)
    OrderMailer.buyer_payment_confirmation(order).deliver_now
    OrderMailer.seller_payment_notification(order).deliver_now
  rescue => e
    Rails.logger.error "Order notification failed for order #{order_id}: #{e.message}"
  end
end
