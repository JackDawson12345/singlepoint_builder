class AddCategoriesToWebsites < ActiveRecord::Migration[8.0]
  def change
    add_column :websites, :categories, :json, default: {"blogs": {},"services": {},"products": {},}
  end
end
