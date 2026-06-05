class Card < ApplicationRecord
  belongs_to :project

  validates :category, presence: true,
                       inclusion: { in: Project::CARD_CATEGORIES },
                       uniqueness: { scope: :project_id }
end
