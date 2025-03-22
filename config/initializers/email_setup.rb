# if Rails.env.production?
# ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.smtp_settings = {
#   :user_name => ENV['SENDGRID_USERNAME'],
#   :password => ENV['SENDGRID_PASSWORD'],
#   :domain => 'navyscredit.com',
#   :address => 'smtp.sendgrid.net',
#   :port => 587,
#   :authentication => :plain,
#   :enable_starttls_auto => true
# }
# end

# config.action_mailer.delivery_method = :postmark
#
# config.action_mailer.postmark_settings = {
#   api_token: ENV['postmark_api_token']
# }

# if Rails.env.production?
#   ActionMailer::Base.smtp_settings = {
#     :port           => ENV['MAILGUN_SMTP_PORT'],
#     :address        => ENV['MAILGUN_SMTP_SERVER'],
#     :user_name      => ENV['MAILGUN_SMTP_LOGIN'],
#     :password       => ENV['MAILGUN_SMTP_PASSWORD'],
#     :domain         => 'navyscredit.com',
#     :authentication => :plain,
#   }
#   ActionMailer::Base.delivery_method = :smtp
# end
if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    :port           => ENV['MAILGUN_SMTP_PORT'],
    :address        => ENV['MAILGUN_SMTP_SERVER'],
    :user_name      => 'support@theaxismarket.com',
    :password       => 'Kizzonia1$',
    :domain         => 'theaxismarket.com',
    :authentication => :plain,
  }
  ActionMailer::Base.delivery_method = :smtp
end
