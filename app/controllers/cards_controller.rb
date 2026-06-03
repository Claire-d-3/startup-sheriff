class CardsController < ApplicationController
  before_action :set_project

  def edit
  end

  def update
    @card = @project.cards.find(params[:id])
    @card.update(card_params)
    redirect_to project_cards_path(@project)
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def card_params
    params.require(:card).permit(:title, :content)
  end
end
