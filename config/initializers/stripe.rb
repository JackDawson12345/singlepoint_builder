# config/initializers/stripe.rb
Rails.configuration.to_prepare do
  Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key) || ENV['STRIPE_SECRET_KEY']
end