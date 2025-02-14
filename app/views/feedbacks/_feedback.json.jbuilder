json.extract! feedback, :id, :title, :icon, :body, :slug, :created_at, :updated_at
json.url feedback_url(feedback, format: :json)
