class CreateComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :components do |t|
      t.string :name
      t.string :component_type
      t.boolean :global
      t.json :content
      t.json :editable_fields
      t.json :field_types
      t.json :template_patterns

      t.timestamps
    end
  end
end
