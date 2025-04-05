class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  mount_uploader :prodimage, ProdimageUploader
  has_many :images, dependent: :destroy
   accepts_nested_attributes_for :images, allow_destroy: true
   
 has_rich_text :description
  belongs_to :category
  belongs_to :sub_category
  belongs_to :user

  has_many :cart_items
 has_many :carts, through: :cart_items
end
