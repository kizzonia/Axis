class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  mount_uploader :prodimage, ProdimageUploader
has_rich_text :description
  belongs_to :category
  belongs_to :sub_category
  belongs_to :user
end
