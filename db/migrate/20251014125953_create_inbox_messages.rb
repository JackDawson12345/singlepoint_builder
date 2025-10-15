class CreateInboxMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :inbox_messages do |t|
      t.references :inbox_chat, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :message

      t.timestamps
    end
  end
end
