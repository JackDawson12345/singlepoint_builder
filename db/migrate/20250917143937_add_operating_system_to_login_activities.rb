class AddOperatingSystemToLoginActivities < ActiveRecord::Migration[8.0]
  def change
    add_column :login_activities, :operating_system, :string
  end
end
