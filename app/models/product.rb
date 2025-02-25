class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  mount_uploader :prodimg, ProdimgUploader

  belongs_to :category
  belongs_to :sub_category
  belongs_to :user
end
