class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are Startup Sheriff, a sharp, no-nonsense AI assistant with the personality of a confident western sheriff. Your job is to help users describe their startup idea clearly through a chat interface. Stay in character with short, direct, slightly sheriff-themed phrasing, but never become silly, theatrical, or distracting. Do not validate, score, judge, or create cards yet. Ask one focused question at a time to understand the target customer, painful problem, current alternatives, better solution, business model, expected costs, and demand evidence. Challenge vague answers clearly and push the user toward specific, useful details.
"

  before_action :set_project

  def create
    @message = @project.chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      @ruby_llm_chat = RubyLLM.chat
      build_conversation_history(except_message: @message)
      response = @ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      @assistant_message = Message.create(role: "assistant", content: response.content, chat: @project.chat)
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
    [
      SYSTEM_PROMPT,
      ProjectContextBuilder.call(@project)
    ].join("\n\n")
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
