module Manage::Website::ProductsHelper
  def format_variant_options(variants_options)
    return "" unless variants_options.is_a?(Hash)

    variants_options.map do |key, values|
      "#{key.humanize}: #{values.join(',')}"
    end.join("\n")
  end
end
