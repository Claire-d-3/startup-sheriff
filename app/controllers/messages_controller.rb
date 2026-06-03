class MessagesController < ApplicationController
  SYSTEM_PROMPT = "You are Startup Sheriff, a direct and focused AI assistant that helps users describe their startup idea clearly through a chat interface.
Your job is not to validate, judge, score, or create cards yet.
Your only goal is to collect clear user input about: the target customer, the painful problem, when the problem happens, current alternatives, why the new solution is better, business model, expected costs, and existing demand evidence.
Ask one short question at a time and challenge vague answers with practical follow-up questions.
Keep the conversation concise, direct, and easy for a founder to answer.
When enough information is collected, summarize the startup idea in structured form and ask the user if they want to continue."

  def create
    @chat = current_user.chats.find(params[:chat_id])
    @project = @chat.project

    @message = Message.new(message_params)
    @message.chat = @chat
    @message.role = "user"

    if @message.save
      ruby_llm_chat = RubyLLM.chat
      response = ruby_llm_chat.with_instructions(instructions).ask(@message.content)
      Message.create(role: "assistant", content: response.content, chat: @chat)

      redirect_to chat_path(@chat)
    else
      render "chats/show", status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content)
  end

  def project_context
    "Here is the context of the project: #{@project.content}."
  end

  def instructions
    [SYSTEM_PROMPT, project_context, @project.system_prompt]
      .compact.join("\n\n")
  end
end
