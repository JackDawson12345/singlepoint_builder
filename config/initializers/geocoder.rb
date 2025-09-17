# config/initializers/geocoder.rb
Geocoder.configure(
  lookup: :ip_api,  # This is the correct lookup name for ip-api.com
  timeout: 3,
  units: :km,
  cache: Rails.cache,
  cache_prefix: 'geocoder:',
  always_raise: [
    Geocoder::OverQueryLimitError,
    Geocoder::RequestDenied,
    Geocoder::InvalidRequest
  ]
)