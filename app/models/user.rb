class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :projects, dependent: :destroy
  has_many :chats, through: :projects
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
