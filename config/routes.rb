Rrroomba::Application.routes.draw do
  get "drive/index"
  get "drive/command"
  root :to => 'drive#index'
end
