module Manage::Settings::Website::SeoSettingsHelper
  def find_outer_page_data(target_page, all_pages)
    all_pages["theme_pages"].find do |page_name, page_data|
      page_data["inner_pages"].any? { |inner_name, inner_data| inner_data["theme_page_id"] == target_page["theme_page_id"] }
    end
  end
end
