class User < ApplicationRecord
  # Include default devise modules with omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook]
  has_many :login_activities, dependent: :destroy

  encrypts :first_address_line, :second_address_line, :town,
           :county, :state_province, :postcode, :country

  has_one :website, dependent: :destroy
  has_one_attached :logo
  has_one_attached :profile_image

  has_many :notifications, dependent: :destroy

  # Association
  has_one :user_setup, dependent: :destroy

  # OAuth connections
  has_many :user_connections, dependent: :destroy

  # Add backup codes for 2FA
  serialize :otp_backup_codes, coder: JSON, type: Array

  # Callback to create UserSetup after user is created
  after_create :create_default_user_setup

  # Add validation for profile image
  validate :acceptable_profile_image

  def get_address_from_ip(ip_address)
    result = Geocoder.search(ip_address).first
    city = result.city
    region = result.region
    country = result.country

    [city, region, country].join(', ')
  end

  # OAuth class method
  def self.from_omniauth(auth)
    # First, try to find existing connection
    connection = UserConnection.find_by(provider: auth.provider, uid: auth.uid)

    if connection
      return connection.user
    end

    # If no connection exists, try to find user by email
    user = User.find_by(email: auth.info.email)

    # If user doesn't exist, create new one
    unless user
      user = User.create!(
        email: auth.info.email,
        password: Devise.friendly_token[0, 20],
        first_name: auth.info.first_name || auth.info.name&.split&.first || auth.info.email.split('@').first.humanize,
        last_name: auth.info.last_name || auth.info.name&.split&.last
      )
    end

    # Create the connection
    user.user_connections.create!(
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      email: auth.info.email,
      image: auth.info.image
    )

    user
  end

  # OAuth helper methods
  def connected_to?(provider)
    user_connections.exists?(provider: provider)
  end

  def connection_for(provider)
    user_connections.find_by(provider: provider)
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def get_name_from_email
    email.split('@')[0]
  end

  def get_role
    if role == 0
      'Admin'
    elsif role == 1
      'Customer'
    end
  end

  def account_setup_done
    if user_setup.nil?
      'Not Required'
    else
      if user_setup.payment_status == 'completed'
        'Completed'
      else
        'Awaiting Payment'
      end
    end
  end

  def domain_name
    if user_setup.nil?
      'Not Required'
    else
      if user_setup.domain_name.nil?
        'Awaiting Domain'
      else
        user_setup.domain_name
      end
    end
  end

  def is_ecommerce
    user_setup.package_type == 'e-commerce'
  end

  # Add these helper methods for name handling
  def full_name
    "#{first_name} #{last_name}".strip if first_name.present? || last_name.present?
  end

  def display_name
    full_name.present? ? full_name : get_name_from_email.humanize
  end

  # 2FA methods using ROTP
  def otp_secret
    return otp_secret_key if otp_secret_key.present?

    # Generate new secret if none exists
    secret = ROTP::Base32.random
    update!(otp_secret_key: secret)
    secret
  end

  # With this:
  def otp_provisioning_uri(label, issuer:)
    totp = ROTP::TOTP.new(otp_secret)
    Rails.logger.info "ROTP TOTP methods: #{totp.method(:provisioning_uri).parameters}"
    totp.provisioning_uri(label)
  end

  def validate_and_consume_otp!(token)
    totp = ROTP::TOTP.new(otp_secret)
    last_consumed = consumed_timestep || 0

    # Verify the token and ensure it hasn't been used before
    if totp.verify(token, drift_behind: 60, drift_ahead: 60, after: Time.at(last_consumed))
      # Update the last consumed timestep to prevent replay attacks
      self.consumed_timestep = Time.current.to_i
      save!
      return true
    end

    false
  end

  def invalidate_otp_backup_code!(code)
    return false unless otp_backup_codes&.include?(code)

    otp_backup_codes.delete(code)
    save!
    true
  end

  # Generate backup codes
  def generate_two_factor_backup_codes!
    codes = []
    10.times do
      codes << SecureRandom.hex(6)
    end
    self.otp_backup_codes = codes
    save!
    codes
  end

  private

  def create_default_user_setup
    UserSetup.create!(user: self)
  end

  # Add profile image validation
  def acceptable_profile_image
    return unless profile_image.attached?

    unless profile_image.blob.byte_size <= 5.megabyte
      errors.add(:profile_image, "is too big (should be at most 5MB)")
    end

    acceptable_types = ["image/jpeg", "image/jpg", "image/png", "image/gif"]
    unless acceptable_types.include?(profile_image.blob.content_type)
      errors.add(:profile_image, "must be a JPEG, JPG, PNG, or GIF")
    end
  end
end