require "sidekiq/web"
Rails.application.routes.draw do
  # Health check should be first
  get "up" => "rails/health#show", as: :rails_health_check

  # Devise routes
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    omniauth_callbacks: 'users/omniauth_callbacks'
  }
  # Wrap the custom 2FA route in devise_scope
  devise_scope :user do
    get 'users/two_factor', to: 'users/sessions#two_factor', as: :two_factor
  end

  resources :account_connections, only: [:destroy]

  # Admin routes - MUST come before wildcard routes
  namespace :admin do

    mount Sidekiq::Web => "/sidekiq"

    namespace :website do
      get "/", to: "website#index", as: "websites"
      get "/:id/preview", to: "website#show", as: "website_show"
      get "/:id/edit", to: "website#edit", as: "website_edit"
      get "/new", to: "website#new", as: "website_new"
      get "/reports", to: "website#reports", as: "website_reports"

      get "/services/", to: "services#view_all", as: "all_website_services"
      get "/:id/services/", to: "services#index", as: "website_services"
      get "/:id/services/:service_id/edit", to: "services#edit", as: "edit_website_service"
      get "/services/new", to: "services#new", as: "new_website_service"
      get "/services/reports", to: "services#reports", as: "website_services_reports"

      get "/blogs/", to: "blogs#view_all", as: "all_website_blogs"
      get "/:id/blogs/", to: "blogs#index", as: "website_blogs"
      get "/:id/blogs/:blog_id/edit", to: "blogs#edit", as: "edit_website_blog"
      get "/blogs/new", to: "blogs#new", as: "new_website_blog"
      get "/blogs/reports", to: "blogs#reports", as: "website_blogs_reports"

      get "/products/", to: "products#view_all", as: "all_website_products"
      get "/:id/products/", to: "products#index", as: "website_products"
      get "/:id/products/:product_id/edit", to: "products#edit", as: "edit_website_product"
      get "/products/new", to: "products#new", as: "new_website_product"
      get "/products/reports", to: "products#reports", as: "website_products_reports"
    end

    get "/", to: "dashboard#index", as: "dashboard"

    # Media
    resources :media, only: [:index, :create]

    # Components
    get "/components", to: 'components#index', as: 'components'
    get "/components/:id/preview", to: 'components#preview', as: 'component_preview'
    get "/components/new", to: 'components#new', as: 'components_new'
    get "/components/:id", to: 'components#show', as: 'components_show'
    get "/components/:id/edit", to: 'components#edit', as: 'components_edit'
    post "/components", to: 'components#create'
    patch "/components/:id", to: 'components#update'
    put "/components/:id", to: 'components#update'
    delete "/components/:id", to: 'components#destroy'

    # Theme pages routes
    get "/themes/:id/pages/new", to: 'themes#add_page', as: 'add_page'
    post "/themes/:id/pages", to: 'themes#create_pages', as: 'create_pages'
    get "/themes/:id/css", to: 'themes#theme_css', as: 'theme_css'
    post "/themes/:id/css/save", to: 'themes#theme_css_save', as: 'theme_css_save'

    get "/themes/:id/page/:theme_page_id", to: 'theme_pages#index', as: 'theme_page'
    get "/themes/:id/page/:theme_page_id/preview", to: 'theme_pages#preview', as: 'theme_page_preview'
    get "/themes/:id/page/:theme_page_id/inner-page", to: 'theme_pages#inner_page', as: 'theme_page_inner_page'
    patch "themes/:id/theme-page/:theme_page_id/add", to: 'theme_pages#add_component', as: 'theme_pages_add_component'
    delete "/themes/:id/theme-pages/:theme_page_id/remove", to: 'theme_pages#remove_component', as: 'theme_pages_remove_component'
    patch "/themes/:id/theme-pages/:theme_page_id/reorder_components", to: 'theme_pages#reorder_components', as: 'theme_pages_reorder_components'

    patch "themes/:id/theme-page/:theme_page_id/inner-page/add", to: 'theme_pages#inner_add_component', as: 'theme_inner_pages_add_component'
    delete "/themes/:id/theme-pages/:theme_page_id/inner-page/remove", to: 'theme_pages#inner_remove_component', as: 'theme_inner_pages_remove_component'
    patch "/themes/:id/theme-pages/:theme_page_id/inner-page/reorder_components", to: 'theme_pages#inner_reorder_components', as: 'theme_inner_pages_reorder_components'

    # Notifications routes
    get "/notifications", to: 'notifications#index', as: 'notifications'
    get "/notifications/:id", to: 'notifications#show', as: 'notification'
    post "/notifications/:id/read", to: 'notifications#read', as: 'notification_read'

    # Users routes
    get "/users", to: "users#index", as: 'users'
    get "/users/new", to: "users#new", as: "new_user"
    post "/users", to: "users#create"
    get "/users/reports", to: 'users#reports', as: 'user_reports'
    get "/users/:id", to: "users#show", as: "user"
    get "/users/:id/edit", to: "users#edit", as: "edit_user"
    patch "/users/:id", to: "users#update"
    put "/users/:id", to: "users#update"
    delete "/users/:id", to: "users#destroy"
    get "/users/:id/edit_password", to: "users#edit_password", as: "edit_password"
    patch "/users/:id/update_password", to: "users#update_password", as: "update_password"

    get "/users/:id/setup", to: "users#setup_user", as: "user_setup"
    patch "/users/:id/update_setup", to: "users#update_setup", as: "update_setup"

    resources :themes
    get '/themes/:id/settings', to: 'themes#settings', as: 'themes_settings'
    patch '/themes/:id/settings', to: 'themes#update_settings', as: 'themes_update_settings'

  end

  # Manage routes - MUST come before wildcard routes
  namespace :manage do
    namespace :website do
      namespace :editor do
        get "/", to: "website_editor#index", as: "website_editor"
        get "/:page_slug", to: "website_editor#show", as: "website_editor_page"
        get "/:page_slug/:inner_page_slug", to: "website_editor#inner_page", as: "website_editor_inner_page"

        post "/sidebar_data", to: "website_editor#sidebar_data", as: "website_editor_sidebar_data"

        post '/sidebar_editor_fields_data', to: "website_editor#sidebar_editor_fields_data", as: "website_editor_sidebar_editor_fields_data"
        post '/sidebar_editor_fields_save', to: "website_editor#sidebar_editor_fields_save", as: "website_editor_sidebar_editor_fields_save"
        post '/add_section', to: "website_editor#add_section", as: "website_editor_add_section"
        post '/add_section_above', to: "website_editor#add_section_above", as: "website_editor_add_section_above"
        post '/remove_section', to: "website_editor#remove_section", as: "website_editor_remove_section"
        post '/reorder_components', to: "website_editor#reorder_components", as: "website_editor_reorder_components"

        patch 'update_colour_scheme', to: 'website_editor#update_colour_scheme'
        patch 'update_font_scheme', to: 'website_editor#update_font_scheme'
        patch 'update_background_scheme', to: 'website_editor#update_background_scheme'
      end

      get "/", to: "website#index", as: "website"

      get "preview/", to: "preview#index", as: "website_preview"
      get "preview/:page_slug", to: "preview#show", as: "website_preview_page"
      get "preview/:page_slug/:inner_page_slug", to: "preview#inner_page", as: "preview_inner_page"

      namespace :shop do
        post '/products/import_csv', to: 'products#import_csv', as: "products_import_csv"
        get '/products/upload_csv', to: 'products#upload', as: 'products_upload_csv'

        resources :products do
          member do
            delete :remove_image
          end
        end


        get "categories", to: "product_categories#index", as: "categories"
        post "categories/create_category", to: "product_categories#create_category", as: "create_category"

      end

      resources :services do
        collection do
          get :categories
          post :categories, action: :create_category
        end
      end
      resources :blogs do
        collection do
          get :categories
          post :categories, action: :create_category
        end
      end
    end

    get "/", to: "dashboard#index", as: "dashboard"
    get "/setup", to: "setup#index", as: "setup"
    # Domain search routes
    post "/setup/search-domain", to: "setup#search_domain", as: "setup_search_domain"
    post "/setup/select-domain", to: "setup#select_domain", as: "setup_select_domain"
    post "/setup/package", to: "setup#package", as: "setup_package"
    post "/setup/support", to: "setup#support", as: "setup_support"
    # Payment routes
    post "/setup/create-payment-intent", to: "setup#create_payment_intent", as: "setup_create_payment_intent"
    post "/setup/confirm-payment", to: "setup#confirm_payment", as: "setup_confirm_payment"
    # Domain purchase retry route
    post "/setup/retry-domain-purchase", to: "setup#retry_domain_purchase", as: "setup_retry_domain_purchase"
    match "/set-website-theme/:theme_id", to: "setup#set_website_theme", as: "set_website_theme", via: [:get, :post]

    resource :account_settings, only: [:show, :update], path: 'account-settings' do
      member do
        post :generate_2fa_secret
        post :enable_2fa
        patch :update_password
      end

      patch '/update_email', to: 'account_settings#update_email', as: 'update_email'


      get '/email-preferences', to: 'account_settings#email_preferences', as: 'email_preferences'
      patch '/email_preferences/update', to: 'account_settings#update_email_preferences', as: 'update_email_preferences'

      get '/privacy-preferences', to: 'account_settings#privacy_preferences', as: 'privacy_preferences'

    end

    # Settings
    namespace :settings do
      namespace :payments do
        get "/accept-payments", to: "accept_payments#accept_payments", as: "accept_payments"
        get "/accept-payments/more", to: "accept_payments#accept_more_payments", as: "accept_more_payments"
      end
      namespace :website do
        # Website Settings Controller
        get "website-settings", to: "website_settings#website_settings", as: "website_settings"
        patch "website-settings", to: "website_settings#update_website"
        delete "website-settings/favicon", to: "website_settings#remove_favicon", as: "remove_favicon"
        patch 'website-settings/update_website_name', to: 'website_settings#update_website_name', as: 'update_website_name'
        post "website-settings", to: "website_settings#publish_website", as: "publish_website"
        # SEO Settings Controller
        get "/seo", to: "seo_settings#seo_settings", as: "seo_settings"
        get "/seo/main-page-settings", to: "seo_settings#main_page_settings", as: "seo_main_page_settings"
        patch 'seo/main-page-settings/seo-settings', to: 'seo_settings#update_seo_field', as: "seo_update_seo_field"
        get "/seo/blog-posts-settings", to: "seo_settings#blog_posts_settings", as: "seo_blog_posts_settings"
        get "/seo/blog-categories-settings", to: "seo_settings#blog_categories_settings", as: "seo_blog_categories_settings"
        get "/seo/services-settings", to: "seo_settings#services_settings", as: "seo_services_settings"
        get "/seo/service-categories-settings", to: "seo_settings#service_categories_settings", as: "seo_service_categories_settings"
        get "/seo/products-settings", to: "seo_settings#products_settings", as: "seo_products_settings"
        get "/seo/product-categories-settings", to: "seo_settings#product_categories_settings", as: "seo_product_categories_settings"
        # Website Settings Controller
        get "/domains", to: "domains#index", as: "domains_index"

      end
      namespace :general do
        get "/business-info", to: "business_info#business_info", as: "business_info"
        patch '/business-info/update-business-info', to: 'business_info#update_business_info', as: 'update_business_info'
        patch '/business-info/update-business-location', to: 'business_info#update_business_location', as: 'update_business_location'
        patch '/business-info/update-business-contact', to: 'business_info#update_business_contact', as: 'update_business_contact'
      end
      get "/", to: "home#index", as: "settings"
    end
  end

  # Specific frontend routes
  get '/about', to: 'frontend#about', as: 'about'
  get '/contact', to: 'frontend#contact', as: 'contact'
  get '/themes', to: 'frontend#themes', as: 'themes'

  # www. domain routes for custom domains (inner pages and single pages)
  get '/:page_slug/:inner_page_slug', to: 'frontend#page_slug', constraints: lambda { |req|
    req.host.start_with?('www.') &&
      !req.path.start_with?('/rails/active_storage') &&
      req.params[:page_slug] !~ /^(about|contact|themes)$/ &&
      req.params[:inner_page_slug] !~ /^(about|contact|themes)$/
  }, as: 'www_domain_inner_page'
  get '/:page_slug', to: 'frontend#page_slug', constraints: lambda { |req|
    req.host.start_with?('www.') &&
      !req.path.start_with?('/rails/active_storage') &&
      req.params[:page_slug] !~ /^(about|contact|themes)$/
  }, as: 'www_domain_page'

  # Custom domain constraint routes - MOVED TO END
  constraints(CustomDomainConstraint.new) do
    get '/', to: 'public_websites#show', as: 'custom_domain_root'
    # Inner page routes - must come before the single page_slug route
    get '/:page_slug/:inner_page_slug', to: 'public_websites#show', constraints: {
      page_slug: /[^\/]+/,
      inner_page_slug: /[^\/]+/
    }, as: 'custom_domain_inner_page'
    get '/:page_slug', to: 'public_websites#show', constraints: { page_slug: /[^\/]+/ }
    get '*path', to: 'public_websites#show', constraints: lambda { |req|
      !req.path.start_with?('/rails/active_storage')
    }
  end

  # Main domain page slug routes - after all specific routes
  # Inner page routes for main domain - must come before single page_slug route
  get '/:page_slug/:inner_page_slug', to: 'public_websites#show', constraints: {
    page_slug: /[^\/]+/,
    inner_page_slug: /[^\/]+/
  }, as: 'main_domain_inner_page'
  get '/:page_slug', to: 'public_websites#show', constraints: lambda { |req|
    !req.path.start_with?('/rails/active_storage')
  }

  # Main domain root route - LAST - This will handle localhost in development
  # and production domains appropriately
  root "frontend#home"
end