class HelpKeywords < ActiveRecord::Migration[8.0]
  def change
    add_column :help_articles, :keywords, :json
  end
end
