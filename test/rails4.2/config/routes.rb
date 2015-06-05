Rails.application.routes.draw do
  mount MyEngine::Engine => "/"
  root to: "index#index"

  resources :songs

  get "songs/with_image_tag"
end
