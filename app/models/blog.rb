class Blog < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  mount_uploader :blogimg, BlogimgUploader
end
