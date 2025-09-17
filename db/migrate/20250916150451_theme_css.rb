class ThemeCss < ActiveRecord::Migration[8.0]
  def change
    add_column :themes, :global_css, :text
  end
end
