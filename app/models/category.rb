class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  mount_uploader :cateimg, CateimgUploader
  has_many :sub_categories, dependent: :destroy


end
