require "test_helper"

class CardTest < ActiveSupport::TestCase
  def build_project
    user = User.create!(
      email: "#{SecureRandom.hex(4)}@example.com",
      password: "password123",
      first_name: "Founder"
    )

    user.projects.create!(
      title: "Startup Sheriff",
      problem_context: "Founders struggle to validate ideas",
      current_solution: "They use scattered docs and chats",
      business_model: "Monthly SaaS subscription"
    )
  end

  test "is invalid with a category outside the supported startup analysis cards" do
    project = build_project
    card = project.cards.build(category: "Marketing", content: "Unsupported category")

    assert_not card.valid?
    assert_includes card.errors[:category], "is not included in the list"
  end

  test "is invalid when a project already has a card for the same category" do
    project = build_project
    card = project.cards.build(category: "Problem", content: "Duplicate problem analysis")

    assert_not card.valid?
    assert_includes card.errors[:category], "has already been taken"
  end
end
