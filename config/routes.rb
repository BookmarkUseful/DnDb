require 'soulmate/server'

Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  namespace :api do

    resources :discover, :only => [:index] do
      collection do
        get 'recently_created'
      end
    end

    resources :backgrounds, :only => [:index, :show, :create, :update]

    resources :character_classes, :only => [:index, :show, :create, :update]

    resources :feats, :only => [:index, :show, :create, :update]

    resources :features, :only => [:show]

    resources :items, :only => [:index, :show]

    resources :monsters, :only => [:index, :show]

    resources :skills, :only => [:index, :show]

    resources :sources, :only => [:index, :show]

    resources :spells, :only => [:index, :show, :create, :update]

    resources :subclasses, :only => [:index, :show, :create, :update]

  end

  mount Soulmate::Server, :at => "/autocomplete"
end
