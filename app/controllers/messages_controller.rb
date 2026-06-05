class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are Startup Sheriff, a direct and focused AI assistant that helps users describe their startup idea clearly through a chat interface."

  before_action :set_project

  def create
    @message = @project.chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history(except_message: @message)
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      @assistent_message = Message.create(role: "assistant", content: response.content, chat: @project.chat)
      CardRefresher.new(project: @project).refresh!

      redirect_to chat_project_path(@project)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def project_context
    @project.startup_context_for_llm
  end

  def instructions
    [SYSTEM_PROMPT, project_context, @project.system_prompt].compact.join("\n\n")
  end

  def message_params
    params.require(:message).permit(:content)
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def build_conversation_history(except_message: nil)
    @project.chat.messages.order(:created_at).each do |message|
      next if except_message.present? && message.id == except_message.id

      @ruby_llm_chat.add_message(message)
    end
  end
end
