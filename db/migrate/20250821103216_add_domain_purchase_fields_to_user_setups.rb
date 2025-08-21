class AddDomainPurchaseFieldsToUserSetups < ActiveRecord::Migration[8.0]
  def change
    add_column :user_setups, :domain_purchased, :boolean, default: false
    add_column :user_setups, :domain_purchase_details, :json
    add_column :user_setups, :domain_purchase_error, :text
  end
end
