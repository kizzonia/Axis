class Category < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  mount_uploader :cateimg, CateimgUploader
  mount_uploader :iconimg, IconimgUploader

  has_many :sub_categories, dependent: :destroy
  has_many :products, through: :sub_categories

end
