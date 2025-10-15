class WebsiteMenu < ActiveRecord::Migration[8.0]
  def change
    add_column :websites, :menu, :jsonb, default: {}
  end
end
