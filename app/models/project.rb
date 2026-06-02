class Project < ApplicationRecord
  belongs_to :user
  has_many :cards, dependant: :destroy
end
