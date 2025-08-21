class Admin::ThemesController < Admin::BaseController
  before_action :set_theme, only: [:show, :edit, :update, :destroy, :add_page, :create_pages]

  def index
    @themes = Theme.all
  end

  def show
    @theme = Theme.find(params[:id])

    unless @theme.pages.nil?
      @themePages = @theme.pages.first[1]
    else
      @themePages = @theme.pages
    end
  end

  def add_page
    @theme = Theme.find(params[:id])

    # Get existing pages to display in the form
    @existing_pages = []
    if @theme.pages && @theme.pages["theme_pages"]
      @theme.pages["theme_pages"].each do |page_name, page_data|
        @existing_pages << {
          "page_name" => page_name.titleize,
          "page_slug" => page_data["slug"],
          "package_type" => page_data["package_type"],
          "theme_page_id" => page_data["theme_page_id"],
          "position" => page_data["position"]
        }
      end
    end

    # Initialize with one empty page structure for new pages
    @new_pages = [{ "page_name" => "", "page_slug" => "", "package_type" => "" }]
  end

  def create_pages
    @theme = Theme.find(params[:id])

    # Get existing pages structure or initialize
    existing_data = @theme.pages || {}
    existing_theme_pages = existing_data["theme_pages"] || {}

    # Calculate the next position
    next_position = existing_theme_pages.length + 1

    # Process new pages from form
    new_pages_data = pages_params
    success_count = 0
    @errors = []

    new_pages_data.each_with_index do |page_data, index|
      # Validate required fields
      if page_data["page_slug"].blank? || page_data["page_name"].blank? || page_data["package_type"].blank?
        @errors << "Page #{index + 1}: All fields are required"
        next
      end

      # Check if slug already exists in current theme
      if existing_theme_pages.values.any? { |page| page["slug"] == page_data["page_slug"] }
        @errors << "Page #{index + 1}: Slug '#{page_data["page_slug"]}' already exists in this theme"
        next
      end

      # Check if page name already exists in current theme
      if existing_theme_pages.key?(page_data["page_name"].downcase)
        @errors << "Page #{index + 1}: Page name '#{page_data["page_name"]}' already exists in this theme"
        next
      end

      # Add to existing theme_pages with page name as key
      existing_theme_pages[page_data["page_name"].downcase] = {
        "theme_page_id" => Time.now.to_i.to_s,
        "components" => [],
        "slug" => page_data["page_slug"],
        "package_type" => page_data["package_type"],
        "position" => (next_position + index).to_s
      }
      success_count += 1
    end

    if @errors.empty?
      # Update the theme with the new structure
      updated_data = existing_data.merge("theme_pages" => existing_theme_pages)
      @theme.update(pages: updated_data)
      redirect_to admin_theme_path(@theme), notice: "#{success_count} page(s) added successfully!"
    else
      @new_pages = new_pages_data
      flash.now[:alert] = "Some pages couldn't be added. Please check the errors below."
      render :add_page
    end
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

  def pages_params
    params.require(:new_pages).values.map do |page_params|
      page_params.permit(:page_name, :page_slug, :package_type)
    end
  end
end