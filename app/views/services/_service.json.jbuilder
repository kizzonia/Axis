json.extract! service, :id, :title, :slug, :icon, :sub_title, :body, :serviceimg, :created_at, :updated_at
json.url service_url(service, format: :json)
