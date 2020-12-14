# frozen_string_literal: true

Rails.application.routes.draw do
  scope :api do
    resources :books
    resources :authors
    resources :publishers
    resources :users, except: :put
    root to: 'books#index'
    # on ajoute le params :text dans l'url du search
    get '/search/:text', to: 'search#index'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
