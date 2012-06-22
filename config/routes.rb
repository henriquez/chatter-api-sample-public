Apibrowser::Application.routes.draw do
  
  root :to => 'home#index' # unauthenticated user landing page

  # Omniauth OAuth routes
  # remote access app callback field must be ../auth/salesforce/callback
  # in view, hit '/auth/salesforce' to initiate login via omniauth
  
  match '/auth/:provider/callback' => 'sessions#create', :as => :oauth_callback
  match '/auth/failure' => 'sessions#failure'
  match '/logout' => 'sessions#destroy', :as => :logout 
  
  # generic controller where non-chatter resources live
  match '/things' => 'things#index'
  
  # all chatter related routes we use to get around SOP
  namespace :chatter do
    match 'feeds/:type' => 'feeds#show'
    match 'feeds' => 'feeds#create', :via => :post
    
    # endpoint to get users that mentions picker matches to
    match 'users/mentions' => 'users#mentions'
    match 'users/photo'   => 'users#photo' #proxy for photo auth
    
    # feed items controller
    match 'feed-items/:feed_item_id/likes' => 'feed_items#like', :via => :post
    match 'feed-items/:feed_item_id' => 'feed_items#destroy', :via => :delete
    #match 'feed-items/:feed_item_id/likes' => 'likes#index', :via => :get
    
    # likes controller
    
    match 'likes/:like_id' => 'likes#destroy', :via => :delete
    
    # comments controller
    match 'comments/:comment_id/likes'     => 'comments#like', :via => :post
    match 'feed-items/:feed_item_id/comments' => 'comments#create', :via => :post
    match 'comments/:comment_id' => 'comments#destroy', :via => :delete
  end
  

  
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
