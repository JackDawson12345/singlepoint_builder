class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_password, :update_password, :setup_user, :update_setup]

  def index
    @users = User.all.order(:created_at)
  end

  def show
    user = User.find(params[:id])
    @payment_intent = get_stripe_details(user)

  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_creation_params)

    if @user.save
      redirect_to admin_user_path(@user), notice: 'User was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: 'User was successfully deleted.'
  end

  def setup_user

  end

  def update_setup
    user = User.find(params[:id])
    setup_params = user_setup_params

    # Add paid_at timestamp when payment is completed
    setup_params[:paid_at] = Time.current if setup_params[:payment_status] == 'completed'

    if user.user_setup.update(setup_params)
      redirect_to admin_user_path(user), notice: 'Setup was successfully updated.'
    else
      # Handle validation errors
      redirect_to admin_user_path(user), alert: 'Failed to update setup: ' +
        user.user_setup.errors.full_messages.join(', ')
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: 'User not found.'
  end

  def edit_password
  end

  def update_password
    if params[:user][:password].blank?
      redirect_to admin_edit_password_path(@user), alert: 'Password cannot be blank.'
      return
    end

    if params[:user][:password] != params[:user][:password_confirmation]
      redirect_to admin_edit_password_path(@user), alert: 'Password and confirmation do not match.'
      return
    end

    if @user.update(password_params)
      redirect_to admin_user_path(@user), notice: 'Password was successfully updated.'
    else
      redirect_to admin_edit_password_path(@user), alert: 'Failed to update password.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_users_path, alert: 'User not found.'
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :role)
  end

  def user_creation_params
    params.require(:user).permit(:first_name, :last_name, :email, :role, :password, :password_confirmation)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def user_setup_params
    params.require(:user).permit(:domain_name, :package_type, :support_option, :payment_status)
  end

  def get_stripe_details(user)
    @payment_intent = Stripe::PaymentIntent.retrieve(user.user_setup.stripe_payment_intent_id)
  end

end
