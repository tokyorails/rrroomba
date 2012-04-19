Rrroomba::Application.routes.draw do
  resources :roombots do
    member do
      get :control
      get :command
      post :reply
    end
  end

  resources :simulations

  resources :schedules, :only => [:update]

  get "drive/index"
  get "drive/command"

  root :to => 'roombots#index'
end
