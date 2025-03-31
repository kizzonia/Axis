module ApplicationHelper
  def custom_bootstrap_flash
  flash_messages = []
  flash.each do |type, message|
    type = 'success' if type == 'notice'
    type = 'error'   if type == 'alert'
    text = "<script>toastr.#{type}('#{message}');</script>"
    flash_messages << text.html_safe if message
  end
  flash_messages.join("\n").html_safe
end

def transaction_status_class(status)
  case status
  when 'completed' then 'success'
  when 'failed' then 'danger'
  when 'pending' then 'warning'
  else 'secondary'
  end
end

def order_status_class(status)
  case status
  when 'paid', 'delivered' then 'success'
  when 'cancelled' then 'danger'
  when 'pending' then 'warning'
  when 'shipped' then 'info'
  else 'secondary'
  end
end


end
