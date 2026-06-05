require "test_helper"

class CardRefresherTest < ActiveSupport::TestCase
  FakeResponse = Struct.new(:content)

  class FakeChatClient
    attr_reader :instructions, :prompt

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def ask(prompt)
      @prompt = prompt
      FakeResponse.new(
        {
          "Problem" => "Founders lack a structured way to pressure-test startup ideas.",
          "Market" => "The market is broad, but no sizing evidence has been provided yet.",
          "Customer" => "The primary customer appears to be early-stage founders.",
          "Competition" => "Competition likely includes mentors, incubators, and generic AI chat tools.",
          "Unit Economics" => "Pricing and acquisition costs are still assumptions.",
          "Demand Signals" => "No strong demand signals have been shared yet."
        }.to_json
      )
    end
  end

  test "updates the six project cards from llm output" do
    user = User.create!(
      email: "cards@example.com",
      password: "password123",
      first_name: "Founder"
    )
    project = user.projects.create!(
      title: "Startup Sheriff",
      problem_context: "Founders struggle to validate ideas",
      current_solution: "They use scattered docs and chats",
      business_model: "Monthly SaaS subscription"
    )
    chat = project.create_chat!(title: "Main chat")
    chat.messages.create!(role: "user", content: "Our customer is solo founders.")
    chat.messages.create!(role: "assistant", content: "That sharpens the customer card.")

    fake_chat_client = FakeChatClient.new

    CardRefresher.new(project: project, chat_client: fake_chat_client).refresh!

    assert_equal(
      "The primary customer appears to be early-stage founders.",
      project.cards.find_by!(category: "Customer").reload.content
    )
    assert_equal(
      "Pricing and acquisition costs are still assumptions.",
      project.cards.find_by!(category: "Unit Economics").reload.content
    )
    assert_includes fake_chat_client.prompt, "Our customer is solo founders."
    assert_includes fake_chat_client.prompt, "Problem"
  end
end
