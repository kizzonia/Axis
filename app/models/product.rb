class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  mount_uploader :prodimage, ProdimageUploader

  belongs_to :category
  belongs_to :sub_category
  belongs_to :user
end
