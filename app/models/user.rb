class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  encrypts :first_address_line, :second_address_line, :town,
           :county, :state_province, :postcode, :country

  has_one :website, dependent: :destroy

  has_many :notifications, dependent: :destroy

  # Association
  has_one :user_setup, dependent: :destroy

  # Callback to create UserSetup after user is created
  after_create :create_default_user_setup

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

  private

  def create_default_user_setup
    UserSetup.create!(user: self)
  end

end
