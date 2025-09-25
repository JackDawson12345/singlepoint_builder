class CreateInvoiceTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :invoice_templates do |t|
      t.references :website, null: false, foreign_key: true

      t.json :numbering
      t.json :header_fields
      t.json :business_info
      t.json :customer_details
      t.json :items_tax_display
      t.json :footer_notes
      t.json :design

      t.timestamps
    end
  end
end
