class AddSettingsToThemesAndWebsites < ActiveRecord::Migration[8.0]
  def change
    add_column :themes, :settings, :json
    add_column :websites, :settings, :json
  end
end
