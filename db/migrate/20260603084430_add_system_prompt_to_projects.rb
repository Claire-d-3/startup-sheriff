class AddSystemPromptToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :system_prompt, :text
  end
end
