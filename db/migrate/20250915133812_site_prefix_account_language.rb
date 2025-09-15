class SitePrefixAccountLanguage < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :site_url_prefix, :string
    add_column :users, :account_language, :string
  end
end
