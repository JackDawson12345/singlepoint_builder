class CreatePageTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :page_templates do |t|
      t.string :title
      t.string :page_type
      t.json :components

      t.timestamps
    end
  end
end
