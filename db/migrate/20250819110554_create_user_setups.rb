class CreateUserSetups < ActiveRecord::Migration[8.0]
  def change
    create_table :user_setups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :domain_name
      t.string :package_type
      t.string :support_option
      t.string :payment_status
      t.string :stripe_payment_intent_id
      t.string :paid_at
      t.references :theme, null: false, foreign_key: true
      t.string :built_website, default: 'Not Started'
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
