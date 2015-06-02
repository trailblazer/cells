Rails.application.routes.draw do
  mount MyEngine::Engine => "/"
  root to: "index#index"

  resources :songs
end
