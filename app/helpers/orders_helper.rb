module OrdersHelper
  def status_class(status)
    case status.downcase
    when "delivered"
      "style1"
    when "cancel"
      "style2"
    when "in progress"
      "style3"
    else
      ""
    end
  end
end
