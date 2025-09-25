class DefaultInvoiceDesign < ActiveRecord::Migration[8.0]
  def change
    change_column_default :invoice_templates, :design, from: nil, to:  {
      "text": {
        "headline": {
          "font": "roboto",
          "size": "30px",
          "style": {
            "bold": "true",
            "underline": "false",
            "italic": "false"
          },
          "color": "#000000"
        },
        "title": {
          "font": "roboto",
          "size": "14px",
          "style": {
            "bold": "true",
            "underline": "false",
            "italic": "false"
          },
          "color": "#000000"
        },
        "text": {
          "font": "roboto",
          "size": "12px",
          "style": {
            "bold": "false",
            "underline": "false",
            "italic": "false"
          },
          "color": "#000000"
        },
        "items": {
          "font": "roboto",
          "size": "12px",
          "style": {
            "bold": "false",
            "underline": "false",
            "italic": "false"
          },
          "color": "#000000"
        }
      },
      "divider": "divider-1",
      "image": {
        "has_image": "false"
      }
    }

  end
end
