json.extract! blog, :id, :title, :sub_title, :body, :blogimg, :videolink, :blogvideoimg, :slug, :created_at, :updated_at
json.url blog_url(blog, format: :json)
