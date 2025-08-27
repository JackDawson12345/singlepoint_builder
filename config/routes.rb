Rails.application.routes.draw do
  root "frontend#home"
  get "frontend/about"
  get "frontend/themes"
  get "frontend/contact"

  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  namespace :admin do
    get "/", to: "dashboard#index", as: "dashboard"

    # Components
    get "/components", to: 'components#index', as: 'components'
    get "/components/new", to: 'components#new', as: 'components_new'
    get "/components/:id", to: 'components#show', as: 'components_show'
    get "/components/:id/edit", to: 'components#edit', as: 'components_edit'
    post "/components", to: 'components#create'
    patch "/components/:id", to: 'components#update'
    put "/components/:id", to: 'components#update'
    delete "/components/:id", to: 'components#destroy'

    # Theme pages routes
    get "/themes/:id/pages/new", to: 'themes#add_page', as: 'add_page'
    post "/themes/:id/pages", to: 'themes#create_pages', as: 'create_pages'  # Add this line

    get "/themes/:id/page/:theme_page_id", to: 'theme_pages#index', as: 'theme_page'
    patch "themes/:id/theme-page/:theme_page_id/add", to: 'theme_pages#add_component', as: 'theme_pages_add_component'
    delete "/themes/:id/theme-pages/:theme_page_id/remove", to: 'theme_pages#remove_component', as: 'theme_pages_remove_component'
    patch "/themes/:id/theme-pages/:theme_page_id/reorder_components", to: 'theme_pages#reorder_components', as: 'theme_pages_reorder_components'

    resources :themes
  end

  namespace :manage do
    namespace :website do
      namespace :editor do
        get "/", to: "website_editor#index", as: "website_editor"
        get "/:page_slug", to: "website_editor#show", as: "website_editor_page"
      end

      get "/", to: "website#index", as: "website"

      resources :products do
        member do
          delete :remove_image
        end
      end

    end

    get "/", to: "dashboard#index", as: "dashboard"
    get "/setup", to: "setup#index", as: "setup"

    # Domain search routes
    post "/setup/search-domain", to: "setup#search_domain", as: "setup_search_domain"
    post "/setup/select-domain", to: "setup#select_domain", as: "setup_select_domain"

    # Fixed this line:
    post "/setup/package", to: "setup#package", as: "setup_package"
    post "/setup/support", to: "setup#support", as: "setup_support"

    # Payment routes
    post "/setup/create-payment-intent", to: "setup#create_payment_intent", as: "setup_create_payment_intent"
    post "/setup/confirm-payment", to: "setup#confirm_payment", as: "setup_confirm_payment"

    # Domain purchase retry route (NEW)
    post "/setup/retry-domain-purchase", to: "setup#retry_domain_purchase", as: "setup_retry_domain_purchase"

    match "/set-website-theme/:theme_id", to: "setup#set_website_theme", as: "set_website_theme", via: [:get, :post]

    # Settings
    get "/settings", to: "settings#index", as: "settings"
    get "/settings/website-settings", to: "settings#website_settings", as: "website_settings"
  end
end