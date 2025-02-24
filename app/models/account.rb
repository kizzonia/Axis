class Account < ApplicationRecord
  belongs_to :user
  validates_uniqueness_of :username

end
