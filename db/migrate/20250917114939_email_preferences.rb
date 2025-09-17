class EmailPreferences < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_preferences, :json, default: {"special_offers": true, "contests_and_events": true, "new_features_and_releases": true, "tips_and_inspiration": true,}
  end
end
