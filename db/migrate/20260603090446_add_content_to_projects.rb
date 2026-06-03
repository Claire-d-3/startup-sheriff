class AddContentToProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :projects, :content, :text
  end
end
