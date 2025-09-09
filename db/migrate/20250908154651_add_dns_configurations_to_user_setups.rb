class AddDnsConfigurationsToUserSetups < ActiveRecord::Migration[8.0]
  def change
    add_column :user_setups, :dns_configurations, :json, default: {}
  end
end
