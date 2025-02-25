class Category < ApplicationRecord
  mount_uploader :cateimg, CateimgUploader
  has_many :sub_categories, dependent: :destroy


end
