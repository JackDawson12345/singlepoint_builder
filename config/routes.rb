Rails.application.routes.draw do
  root "frontend#home"
  get "frontend/about"
  get "frontend/themes"
  get "frontend/contact"

  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  namespace :admin do
    get "/", to: "dashboard#index", as: "dashboard"
    resources :themes
  end

  namespace :manage do
    namespace :website do
      namespace :editor do
        get "/", to: "website_editor#index", as: "website_editor"
      end

      get "/", to: "website#index", as: "website"
      match "/set-website-theme/:theme_id", to: "website#set_website_theme", as: "set_website_theme", via: [:get, :post]
    end

    get "/", to: "dashboard#index", as: "dashboard"
    get "/setup", to: "setup#index", as: "setup"

    # Domain search routes
    post "/setup/search-domain", to: "setup#search_domain", as: "setup_search_domain"
    post "/setup/select-domain", to: "setup#select_domain", as: "setup_select_domain"

    # Fixed this line:
    post "/setup/package", to: "setup#package", as: "setup_package"
    post "/setup/support", to: "setup#support", as: "setup_support"

    # Settings
    get "/settings", to: "settings#index", as: "settings"
    get "/settings/website-settings", to: "settings#website_settings", as: "website_settings"
  end
end