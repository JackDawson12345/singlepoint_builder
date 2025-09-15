module Manage::Website::Shop::ProductsHelper
  def format_variant_options(variants_options)
    return "" unless variants_options.is_a?(Hash)

    variants_options.map do |key, values|
      "#{key.humanize}: #{values.join(',')}"
    end.join("\n")
  end

  # Helper method to build category options for the select dropdown
  def build_category_options(user)
    return [] unless user.website&.categories&.dig('products')

    categories = user.website.categories['products']
    options = []

    # First, build a hash of all categories for easy lookup
    category_lookup = {}
    categories.each do |id, category|
      category_lookup[id] = category
    end

    # Build hierarchical options
    categories.each do |id, category|
      # Skip if this category has a parent (we'll handle it in the hierarchy)
      next if category['parent_category'].present?

      # Add top-level category
      options << [category['name'], id]

      # Add child categories with indentation
      add_child_categories(options, category_lookup, id, '  ')
    end

    options
  end

  # Recursive method to add child categories with proper indentation
  def add_child_categories(options, category_lookup, parent_id, indent)
    category_lookup.each do |id, category|
      if category['parent_category'] == parent_id
        options << ["#{indent}#{category['name']}", id]
        # Recursively add children of this category
        add_child_categories(options, category_lookup, id, "#{indent}  ")
      end
    end
  end

  # Get selected categories for the current product
  def selected_categories(product)
    return [] unless product

    # Handle both old single category format and new multiple categories format
    if product.dig('data', 'categories').is_a?(Array)
      product.dig('data', 'categories') || []
    elsif product.dig('data', 'category').present?
      # Convert old single category to array
      [product.dig('data', 'category')]
    else
      []
    end
  end

  # Helper method for rendering hierarchical checkboxes
  def render_category_checkboxes(form, categories, product = nil, parent_id = '', indent_level = 0)
    return ''.html_safe if categories.blank?

    html = ''
    selected_categories = selected_categories(product)

    # Build category lookup for easier access
    category_lookup = {}
    categories.each { |id, category| category_lookup[id] = category }

    # Get categories for this level
    current_level_categories = categories.select do |id, category|
      category['parent_category'] == parent_id
    end

    current_level_categories.each do |category_id, category|
      indent_class = "category-indent-#{indent_level}" if indent_level > 0
      checked = selected_categories.include?(category_id)

      html += content_tag(:div, class: "flex items-center mb-2 #{indent_class}") do
        checkbox_html = check_box_tag(
          "product[categories][]",
          category_id,
          checked,
          {
            class: "h-4 w-4 text-indigo-600 focus:ring-indigo-500 border-gray-300 rounded mr-2",
            id: "category_#{category_id}"
          }
        )

        label_html = label_tag(
          "category_#{category_id}",
          category['name'],
          class: "text-sm text-gray-700 nata-sans cursor-pointer"
        )

        checkbox_html + label_html
      end

      # Recursively render child categories
      if indent_level < 3 # Prevent too deep nesting
        html += render_category_checkboxes(form, categories, product, category_id, indent_level + 1)
      end
    end

    html.html_safe
  end
end
