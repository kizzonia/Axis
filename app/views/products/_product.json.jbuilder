json.extract! product, :id, :name, :title, :description, :price, :prodimage, :status, :category_id, :sub_category_id, :user_id, :created_at, :updated_at
json.url product_url(product, format: :json)
