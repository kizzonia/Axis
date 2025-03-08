class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable#, :confirmable, :lockable, :timeoutable


  has_many :accounts
  has_many :products, dependent: :destroy
  has_one :cart
 has_many :orders

end
