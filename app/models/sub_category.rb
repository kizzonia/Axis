class SubCategory < ApplicationRecord
  # extend FriendlyId
  # friendly_id :title, use: :slugged

  belongs_to :category
 has_many :products, dependent: :destroy
end
