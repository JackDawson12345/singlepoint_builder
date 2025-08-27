class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :website, dependent: :destroy

  # Association
  has_one :user_setup, dependent: :destroy

  # Callback to create UserSetup after user is created
  after_create :create_default_user_setup

  def get_name_from_email
    email.split('@')[0]
  end

  def is_ecommerce
    user_setup.package_type == 'e-commerce'
  end

  private

  def create_default_user_setup
    UserSetup.create!(user: self)
  end

end
