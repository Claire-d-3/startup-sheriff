class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are Startup Sheriff, a direct and focused AI assistant that helps users describe their startup idea clearly through a chat interface."

  before_action :set_project

  def create
    @message = @project.chat.messages.build(message_params)
    @message.role = "user"

    if @message.save
      chat = RubyLLM.chat
      build_conversation_history(chat)
      response = chat.with_instructions(instructions).ask(@message.content)

      @project.chat.messages.create!(
        role: "assistant",
        content: response.content
      )

      redirect_to chat_project_path(@project)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  # def project_context
  #   "This is my startup idea:
  #   - content : #{@project.content}
  #   - problem context : #{@project.problem_context}
  #   - current solution : #{@project.current_solution}
  #   - business model : #{@project.business_model}"
  # end

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
    @project = Project.find(params[:project_id])
  end

  def build_conversation_history(chat)
    @project.chat.messages.each do |message|
      chat.add_message(
        role: message.role.to_sym,
        content: message.content
      )
    end
  end
end
