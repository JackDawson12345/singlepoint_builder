class Manage::Settings::General::BusinessInfoController < Manage::BaseController
  before_action :set_website, only: [:business_info]
  def business_info
    # @website is already set by before_action
  end

  def update_business_info
    begin
      # Extract parameters
      name = params[:name]
      category = params[:category]
      short_description = params[:short_description]

      # Get existing business_info or initialize empty hash
      # Handle both JSON column and text column with JSON string
      business_info = case current_user.business_info
                      when Hash
                        current_user.business_info.dup
                      when String
                        current_user.business_info.present? ? JSON.parse(current_user.business_info) : {}
                      when NilClass
                        {}
                      else
                        {}
                      end

      # Update only the fields that were provided
      business_info['name'] = name if name.present?
      business_info['category'] = category if category.present?
      business_info['short_description'] = short_description if short_description.present?

      # Handle logo upload if present
      if params[:logo].present?
        current_user.logo.attach(params[:logo])
        business_info['logo_attached'] = true
      end

      # Save back to user - let Rails handle the JSON conversion
      current_user.update!(business_info: business_info)

      flash.now[:notice] = "Business info updated successfully"
      status = 'success'

    rescue JSON::ParserError => e
      Rails.logger.error "JSON Parse Error in business_info: #{e.message}"
      Rails.logger.error "Current business_info value: #{current_user.business_info.inspect}"
      flash.now[:alert] = "Invalid data format. Please try again."
      status = 'error'
    rescue => e
      Rails.logger.error "Error updating business info: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join('\n')}"
      flash.now[:alert] = "Failed to update business info: #{e.message}"
      status = 'error'
    end

    render json: {
      status: status,
      message: flash.now[:notice] || flash.now[:alert],
      flash_type: flash.now[:notice] ? 'notice' : 'alert'
    }
  end

  def update_business_location
    begin
      # Extract location parameters
      location_params = {
        'address_line_one' => params['address_line_one'],
        'address_line_two' => params['address_line_two'],
        'city' => params['city'],
        'zip_postcode' => params['zip_postcode'],
        'country_region' => params['country_region'],
        'street_name' => params['street_name'],
        'house_number' => params['house_number'],
        'apartment_suite_etc' => params['apartment_suite_etc'],
        'location_name' => params['location_name'],
        'address_description' => params['address_description']
      }.compact_blank # Remove empty/nil values

      # Get existing business_info or initialize empty hash
      business_info = case current_user.business_info
                      when Hash
                        current_user.business_info.dup
                      when String
                        current_user.business_info.present? ? JSON.parse(current_user.business_info) : {}
                      when NilClass
                        {}
                      else
                        {}
                      end

      # Update the location nested data
      business_info['location'] = location_params

      # Save back to user
      current_user.update!(business_info: business_info)

      flash.now[:notice] = "Business location updated successfully"
      status = 'success'

    rescue JSON::ParserError => e
      Rails.logger.error "JSON Parse Error in business_info: #{e.message}"
      Rails.logger.error "Current business_info value: #{current_user.business_info.inspect}"
      flash.now[:alert] = "Invalid data format. Please try again."
      status = 'error'
    rescue => e
      Rails.logger.error "Error updating business location: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join('\n')}"
      flash.now[:alert] = "Failed to update business location: #{e.message}"
      status = 'error'
    end

    render json: {
      status: status,
      message: flash.now[:notice] || flash.now[:alert],
      flash_type: flash.now[:notice] ? 'notice' : 'alert'
    }
  end

  def update_business_contact
    begin
      # Extract contact parameters
      email = params['email']
      phone = params['phone']
      fax = params['Fax'] # Note: keeping the capitalized 'Fax' to match your form field

      # Get existing business_info or initialize empty hash
      business_info = case current_user.business_info
                      when Hash
                        current_user.business_info.dup
                      when String
                        current_user.business_info.present? ? JSON.parse(current_user.business_info) : {}
                      when NilClass
                        {}
                      else
                        {}
                      end

      # Update contact fields directly at the root level (not nested)
      business_info['email'] = email if email.present?
      business_info['phone'] = phone if phone.present?
      business_info['fax'] = fax if fax.present?

      # Save back to user
      current_user.update!(business_info: business_info)

      flash.now[:notice] = "Business contact updated successfully"
      status = 'success'

    rescue JSON::ParserError => e
      Rails.logger.error "JSON Parse Error in business_info: #{e.message}"
      Rails.logger.error "Current business_info value: #{current_user.business_info.inspect}"
      flash.now[:alert] = "Invalid data format. Please try again."
      status = 'error'
    rescue => e
      Rails.logger.error "Error updating business contact: #{e.message}"
      Rails.logger.error "Backtrace: #{e.backtrace.first(5).join('\n')}"
      flash.now[:alert] = "Failed to update business contact: #{e.message}"
      status = 'error'
    end

    render json: {
      status: status,
      message: flash.now[:notice] || flash.now[:alert],
      flash_type: flash.now[:notice] ? 'notice' : 'alert'
    }
  end

  def update_social_media
    begin

      byebug

      # Parse the social media data from params
      social_media_data = {}

      if params[:social_media].present?
        params[:social_media].each do |index, data|
          platform = data[:platform]
          link = data[:link]

          # Only save if both platform and link are present
          if platform.present? && link.present?
            # Get the appropriate icon for the platform
            icon = get_social_media_icon(platform)

            social_media_data[platform] = {
              'icon' => icon,
              'link' => link
            }
          end
        end
      end

      # Update the user's business info
      business_info = current_user.business_info || {}
      business_info['social_media'] = social_media_data

      current_user.update!(business_info: business_info)

      render json: {
        message: 'Social media links updated successfully!',
        flash_type: 'notice',
        status: 'success'
      }
    rescue => e
      render json: {
        message: 'Failed to update social media links',
        flash_type: 'alert',
        status: 'error'
      }
    end
  end


  private

  def set_website
    @website = current_user.website
  end

  def get_social_media_icon(platform)
    icons = {
      'facebook' => 'fab fa-facebook-f',
      'instagram' => 'fab fa-instagram',
      'twitter' => 'fab fa-twitter',
      'linkedin' => 'fab fa-linkedin-in',
      'youtube' => 'fab fa-youtube',
      'tiktok' => 'fab fa-tiktok',
      'pinterest' => 'fab fa-pinterest-p',
      'snapchat' => 'fab fa-snapchat-ghost'
    }

    icons[platform] || 'fas fa-link'
  end

end
