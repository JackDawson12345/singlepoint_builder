class AddBusinessInfo < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :business_info, :json
  end
end
