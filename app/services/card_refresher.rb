class CardRefresher
  EXTRACTION_PROMPT = <<~PROMPT
    You maintain six startup analysis cards for a project.

    Return a strict JSON object with exactly these keys:
    - Problem
    - Market
    - Customer
    - Competition
    - Unit Economics
    - Demand Signals

    Rules:
    - Use the project context as the fixed source of truth for the startup itself.
    - Use the conversation to improve the analysis of the six cards.
    - Update a card when the conversation adds useful analysis, evidence, assumptions, or risks.
    - Do not invent facts. If information is missing, say so explicitly.
    - Keep each card concise and practical.
    - Return JSON only. No markdown fences, prose, or comments.
  PROMPT

  def initialize(project:, chat_client: RubyLLM.chat)
    @project = project
    @chat_client = chat_client
  end

  def refresh!
    response = chat_client.with_instructions(EXTRACTION_PROMPT).ask(refresh_request)
    update_cards!(extract_card_contents(response.content))
    project.cards
  end

  private

  attr_reader :project, :chat_client

  def refresh_request
    <<~PROMPT
      Fixed project context:
      #{project.startup_context_for_llm}

      Current cards:
      #{current_cards.to_json}

      Conversation history:
      #{conversation_history}
    PROMPT
  end

  def current_cards
    project.cards.each_with_object({}) do |card, cards|
      cards[card.category] = card.content
    end
  end

  def conversation_history
    project.chat.messages.order(:created_at).map do |message|
      "#{message.role}: #{message.content}"
    end.join("\n")
  end

  def extract_card_contents(raw_content)
    parsed = JSON.parse(strip_json_fence(raw_content))
    parsed.slice(*Project::CARD_CATEGORIES)
  rescue JSON::ParserError
    {}
  end

  def update_cards!(contents_by_category)
    project.cards.find_each do |card|
      next unless contents_by_category.key?(card.category)

      card.update!(content: contents_by_category[card.category].to_s)
    end
  end

  def strip_json_fence(raw_content)
    raw_content.to_s.strip.sub(/\A```json\s*/i, "").sub(/\s*```\z/, "")
  end
end
