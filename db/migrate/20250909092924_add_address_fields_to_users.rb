class AddAddressFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :first_address_line, :string
    add_column :users, :second_address_line, :string
    add_column :users, :town, :string
    add_column :users, :county, :string
    add_column :users, :state_province, :string
    add_column :users, :postcode, :string
    add_column :users, :country, :string
  end
end
