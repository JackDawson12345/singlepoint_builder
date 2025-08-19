# app/controllers/admin/themes_controller.rb
class Admin::ThemesController < ApplicationController
  before_action :set_theme, only: [:show, :edit, :update, :destroy]

  def index
    @themes = Theme.all
  end

  def show
  end

  def new
    @theme = Theme.new
  end

  def create
    @theme = Theme.new(theme_params)

    if @theme.save
      redirect_to admin_theme_path(@theme), notice: 'Theme was successfully created.'
    else
      # Add this to see what errors are occurring
      puts "Theme errors: #{@theme.errors.full_messages}"
      render :new
    end
  end

  def edit
  end

  def update
    if @theme.update(theme_params)
      redirect_to admin_theme_path(@theme), notice: 'Theme was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @theme.destroy
    redirect_to admin_themes_path, notice: 'Theme was successfully deleted.'
  end

  private

  def set_theme
    @theme = Theme.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:name, :description, :image, :pages).tap do |permitted|
      if permitted[:pages].present?
        # Convert comma-separated string to array
        permitted[:pages] = permitted[:pages].split(',').map(&:strip).reject(&:blank?)
      end
    end
  end
end