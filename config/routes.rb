require 'soulmate/server'

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  get  'welcome/index'
  root 'welcome#index'

  namespace :api do
    resources :spells, :only => [:index, :show, :create, :update, :destroy] do
    end
    resources :character_classes, :only => [:index, :show, :update] do
    end
    resources :class_features, :only => [:show] do
    end
    resources :items, :only => [:index] do
    end
    resources :sources, :only => [:index, :show] do
    end
    resources :monsters, :only => [:index] do
    end
    resources :skills, :only => [:index] do
    end
  end

  resources :items

  resources :sources do
    collection do
      get 'index'
    end
    member do
      get ':id' => 'sources#show'
    end
  end

  resources :spells do
    collection do
      get 'index'
    end
    member do
      get ':id' => 'spells#show'
      put ':id' => 'spells#update'
    end
  end

  resources :character_classes do
    collection do
      get 'index'
    end
    member do
      get ':id' => 'character_classes#show'
    end
  end

  mount Soulmate::Server, :at => "/autocomplete"

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
