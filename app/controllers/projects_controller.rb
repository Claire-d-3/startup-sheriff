class ProjectsController < ApplicationController
  before_action :authenticate_user!
  def index
    @projects = current_user.projects
  end

  def show
    @project = current_user.projects.find(params[:id])
    @cards = @project.cards
    # @chats = @project.chats.where(user: current_user)
    @chats = @project.chats
  end

  def new
    @project = current_user.projects.new
    # @chat = Chat.new(chat_params)
  end

  def create
    @project = current_user.projects.new(project_params)
    @project.user = current_user
    if @project.save
      redirect_to project_path(@project.id)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @project = current_user.projects.find(params[:id])
    @project.destroy
    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:title)
  end
end
