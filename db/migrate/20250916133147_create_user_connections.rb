class CreateUserConnections < ActiveRecord::Migration[8.0]
  def change
    create_table :user_connections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name
      t.string :email
      t.string :image

      t.timestamps
    end

    add_index :user_connections, [:provider, :uid], unique: true
  end
end
