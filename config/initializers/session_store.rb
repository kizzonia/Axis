# config/initializers/session_store.rb

if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
    key: '_ecommerce_wallet_session',
    domain: 'www.theaxismarket.com', # If using custom domain
    secure: true,
    same_site: :lax,
    expire_after: 2.weeks
else
  Rails.application.config.session_store :cookie_store,
    key: '_ecommerce_wallet_session_dev'
end
