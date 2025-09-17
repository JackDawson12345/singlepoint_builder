class CreateLoginActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :login_activities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :ip_address
      t.text :user_agent
      t.string :location
      t.string :device
      t.string :browser
      t.datetime :login_at
      t.string :city
      t.string :country

      t.timestamps
    end

  end
end
