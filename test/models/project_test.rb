require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "creates the six default cards for a new project" do
    user = User.create!(
      email: "founder@example.com",
      password: "password123",
      first_name: "Founder"
    )

    project = user.projects.create!(
      title: "Sheriff AI",
      problem_context: "Founders struggle to validate ideas",
      current_solution: "They use scattered docs and chats",
      business_model: "Monthly SaaS subscription"
    )

    assert_equal Project::CARD_CATEGORIES, project.cards.order(:created_at).pluck(:category)
    assert_equal 6, project.cards.count
  end

  test "syncs content from the startup fields" do
    project = Project.new(
      title: "Sheriff AI",
      problem_context: "Founders struggle to validate ideas",
      current_solution: "They use scattered docs and chats",
      business_model: "Monthly SaaS subscription"
    )

    project.valid?

    assert_equal(
      "Sheriff AI\n\nFounders struggle to validate ideas\n\nThey use scattered docs and chats\n\nMonthly SaaS subscription",
      project.content
    )
  end
end
