Rails.application.routes.draw do
  devise_for :users

  root to: "games#index"

  resources :games, only: [:index, :new, :create, :show] do
    post :play, on: :member
  end
end
