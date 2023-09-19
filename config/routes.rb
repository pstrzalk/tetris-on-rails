Rails.application.routes.draw do
  resources :games, only: %i[create index] do
    member do
      patch :register
    end

    collection do
      get :play
      get :move_left
      get :move_right
      get :rotate
      patch :answer
    end
  end

  root to: "games#index"
end
