# config/initializers/geocoder.rb
Geocoder.configure(
  lookup: :ipapi_com,
  timeout: 3,
  units: :km,
  cache: Rails.cache,
  cache_prefix: 'geocoder:',
  # Handle errors gracefully
  always_raise: [
    Geocoder::OverQueryLimitError,
    Geocoder::RequestDenied,
    Geocoder::InvalidRequest
  ]
)