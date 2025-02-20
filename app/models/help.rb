class Help < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  has_many :supports
end
