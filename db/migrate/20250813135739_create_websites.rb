class CreateWebsites < ActiveRecord::Migration[8.0]
  def change
    create_table :websites do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :theme, null: false, foreign_key: true
      t.string :domain_name
      t.string :name
      t.text :description
      t.json :pages
      t.json :customisations
      t.json :services
      t.json :blogs
      t.json :products
      t.boolean :published

      t.timestamps
    end
  end
end
