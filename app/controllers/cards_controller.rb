class CardsController < ApplicationController
  before_action :set_project

  def edit
  end

  def update
    @card = @project.cards.find(params[:id])
    @card.update(card_params)
    redirect_to project_cards_path(@project)
  end

  #   def create
  #     @card = Card.new(card_params)
  #     @card.created = RubyLLM.chat.ask("You are Startup Sheriff, a direct and critical AI startup validation assistant.
  # Based only on the user’s answers for problem_context, current_solution, and business_model, create exactly 6 validation cards: Competition, Market, Customer, Unit Economics, Demand Signals, and Overall Verdict.
  # Do not invent fake facts, competitors, market sizes, pricing, traction, or demand signals.
  # If information is missing, clearly mark it as unknown or assumption.
  # Each card must include: title, score from 0 to 100, summary, key_insights, assumptions, red_flags, and next_steps.
  # : #{@card.long}").content
  #     if @card.save
  #       redirect_to card_path(@card), notice: "Cards successfully created."
  #     else
  #       render :new, status: :unprocessable_entity
  #     end
  #   end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def card_params
    params.require(:card).permit(:title, :content)
  end
end
