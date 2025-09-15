module Manage::Website::BlogsHelper

  def seo_state(category)
    focus_keyword = category['seo']['focus_keyword']
    title_tag = category['seo']['title_tag']
    meta_description = category['seo']['meta_description']

    seo_fields = [focus_keyword, title_tag, meta_description]

    if seo_fields.all?(&:blank?)
      'bg-red-500'    # All are blank
    elsif seo_fields.any?(&:blank?)
      'bg-yellow-500' # Some are blank, some are not
    else
      'bg-green-500'  # None are blank (all have content)
    end

  end

end
