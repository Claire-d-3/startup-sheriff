class Project < ApplicationRecord
  CARD_CATEGORIES = [
    "Problem",
    "Market",
    "Customer",
    "Competition",
    "Unit Economics",
    "Demand Signals"
  ].freeze

  belongs_to :user
  has_many :cards, dependent: :destroy
  has_one :chat, dependent: :destroy

  before_validation :sync_content_from_context
  after_create :create_default_cards

  def startup_context
    {
      title: title,
      problem_context: problem_context,
      current_solution: current_solution,
      business_model: business_model,
      content: content
    }
  end

  def startup_context_for_llm
    <<~TEXT
      This is the current startup context:
      - title: #{title.presence || "Unknown"}
      - problem context: #{problem_context.presence || "Unknown"}
      - current solution: #{current_solution.presence || "Unknown"}
      - business model: #{business_model.presence || "Unknown"}
      - summary: #{content.presence || "Unknown"}
    TEXT
  end

  private

  def create_default_cards
    CARD_CATEGORIES.each do |category|
      cards.find_or_create_by!(category: category) do |card|
        card.content = ""
      end
    end
  end

  def sync_content_from_context
    self.content = [
      title.presence,
      problem_context.presence,
      current_solution.presence,
      business_model.presence
    ].compact.join("\n\n")
  end
end
