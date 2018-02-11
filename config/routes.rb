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
    resources :spells, :only => [:index, :show, :create, :update, :destroy] do
    end
    resources :character_classes, :only => [:index, :show, :update] do
    end
    resources :subclasses, :only => [:index, :show, :update, :create] do
    end
    resources :features, :only => [:show] do
    end
    resources :items, :only => [:index] do
    end
    resources :sources, :only => [:index, :show] do
    end
    resources :monsters, :only => [:index] do
    end
    resources :skills, :only => [:index, :show] do
    end
    resources :feats, :only => [:index, :show, :create, :update] do
    end
  end

  mount Soulmate::Server, :at => "/autocomplete"
end
