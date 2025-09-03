Rails.application.routes.draw do
  root "frontend#home"
  get "frontend/about"
  get "frontend/themes"
  get "frontend/contact"

  get "up" => "rails/health#show", as: :rails_health_check

  devise_for :users

  namespace :admin do
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
    post "/themes/:id/pages", to: 'themes#create_pages', as: 'create_pages'  # Add this line

    get "/themes/:id/page/:theme_page_id", to: 'theme_pages#index', as: 'theme_page'
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
    post "/users", to: "users#create"                    # ADD THIS LINE
    get "/users/reports", to: 'users#reports', as: 'user_reports'
    get "/users/:id", to: "users#show", as: "user"
    get "/users/:id/edit", to: "users#edit", as: "edit_user"
    patch "/users/:id", to: "users#update"              # ADD THIS LINE
    put "/users/:id", to: "users#update"                # ADD THIS LINE
    delete "/users/:id", to: "users#destroy"            # ADD THIS LINE
    # Add these to your users routes in admin namespace:
    get "/users/:id/edit_password", to: "users#edit_password", as: "edit_password"
    patch "/users/:id/update_password", to: "users#update_password", as: "update_password"

    get "/users/:id/setup", to: "users#setup_user", as: "user_setup"
    patch "/users/:id/update_setup", to: "users#update_setup", as: "update_setup"

    resources :themes
  end

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

      end

      get "/", to: "website#index", as: "website"

      get "preview/", to: "preview#index", as: "website_preview"
      get "preview/:page_slug", to: "preview#show", as: "website_preview_page"
      get "preview/:page_slug/:inner_page_slug", to: "preview#inner_page", as: "preview_inner_page"

      resources :products do
        member do
          delete :remove_image
        end
      end

      resources :services do
      end
      resources :blogs do
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