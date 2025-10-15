class CreateHelpArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :help_articles do |t|
      t.string :title
      t.text :text
      t.json :images
      t.references :user, null: false, foreign_key: true
      t.integer :priority

      t.timestamps
    end
  end
end
