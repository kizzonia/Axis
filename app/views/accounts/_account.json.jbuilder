json.extract! account, :id, :balance, :slug, :revenue, :status, :verify, :user_id, :created_at, :updated_at
json.url account_url(account, format: :json)
