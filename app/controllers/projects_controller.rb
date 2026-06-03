class ProjectsController < ApplicationController
  before_action :authenticate_user!
  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
    @cards = @project.cards
    # @chats = @project.chats.where(user: current_user)
    @chats = @project.chats
  end

  def new
    @project = Project.new
    # @chat = Chat.new(chat_params)
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to project_path(@project.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:title)
  end
end
