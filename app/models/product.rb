class Product < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  mount_uploader :prodimage, ProdimageUploader

  def self.ransackable_attributes(auth_object = nil)
    authorizable_ransackable_attributes
  end

  def self.ransackable_associations(auth_object = nil)
    authorizable_ransackable_associations
  end
  has_rich_text :description
  belongs_to :category
  belongs_to :sub_category
  belongs_to :user

  has_many :cart_items
 has_many :carts, through: :cart_items
end
