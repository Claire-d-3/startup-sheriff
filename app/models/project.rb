class Project < ApplicationRecord
  belongs_to :user
  has_many :cards, dependent: :destroy
  has_many :chats, dependent: :destroy
end
