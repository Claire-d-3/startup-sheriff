class CreateCards < ActiveRecord::Migration[8.1]
  def change
    create_table :cards do |t|
      t.string :category
      t.text :content
      t.references :project, null: false, foreign_key: true

      t.timestamps
    end
  end
end
