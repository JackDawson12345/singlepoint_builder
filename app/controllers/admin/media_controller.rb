class Admin::MediaController < Admin::BaseController
  require 'aws-sdk-s3'
  def index
    bucket_name = Rails.application.credentials.dig(:aws, :bucket) || ENV['S3_BUCKET']
    @images = get_all_images(bucket_name)
  end

  def create
    if params[:images].present?
      uploaded_count = 0

      # Filter out empty strings and only process actual file uploads
      params[:images].reject(&:blank?).each do |image|
        next unless image.respond_to?(:tempfile) # Make sure it's an uploaded file

        # Create Active Storage attachment (this will automatically upload to S3)
        blob = ActiveStorage::Blob.create_and_upload!(
          io: image.tempfile,  # Use .tempfile instead of .open
          filename: image.original_filename,
          content_type: image.content_type
        )
        uploaded_count += 1
      end

      if uploaded_count > 0
        redirect_to admin_media_path, notice: "Successfully uploaded #{uploaded_count} image#{uploaded_count > 1 ? 's' : ''}!"
      else
        redirect_to admin_media_path, alert: "No valid images were uploaded."
      end
    else
      redirect_to admin_media_path, alert: "Please select at least one image to upload."
    end
  rescue => e
    Rails.logger.error "Upload error: #{e.message}"
    redirect_to admin_media_path, alert: "Upload failed: #{e.message}"
  end

  private

  def get_all_images(bucket_name)
    return [] unless bucket_name

    begin
      images = []

      s3_client.list_objects_v2(bucket: bucket_name).each do |response|
        response.contents.each do |object|
          # Filter for common image extensions or Active Storage keys (no extension)
          # if object.key.match?(/\.(jpg|jpeg|png|gif|bmp|svg|webp)$/i) || !object.key.include?('.')
          # Find the Active Storage blob by key
          blob = ActiveStorage::Blob.find_by(key: object.key)

          if blob
            images << {
              key: object.key,
              filename: blob.filename.to_s,
              content_type: blob.content_type,
              size: object.size,
              last_modified: object.last_modified,
              blob: blob
            }
          else
            # Fallback for non-Active Storage files
            images << {
              key: object.key,
              url: "https://#{bucket_name}.s3.amazonaws.com/#{object.key}",
              filename: object.key,
              content_type: 'unknown',
              size: object.size,
              last_modified: object.last_modified,
              blob: nil
            }
          end
          # end
        end
      end

      images
    rescue Aws::S3::Errors::ServiceError => e
      Rails.logger.error "S3 Error: #{e.message}"
      []
    end
  end

  def s3_client
    @s3_client ||= Aws::S3::Client.new(
      region: Rails.application.credentials.dig(:aws, :region) || ENV['AWS_REGION'],
      access_key_id: Rails.application.credentials.dig(:aws, :access_key_id) || ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key) || ENV['AWS_SECRET_ACCESS_KEY']
    )
  end
end
