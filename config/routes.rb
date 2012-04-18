Rrroomba::Application.routes.draw do
  resources :roombots do
    member do
      get :control
      get :command
      get :reply
    end
  end

  resources :simulations

  resource :schedule, :except => [:destroy]

  get "drive/index"
  get "drive/command"

  root :to => 'roombots#index'
end
