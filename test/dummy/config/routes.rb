Dummy::Application.routes.draw do
  match ':controller(/:action(/:id(.:format)))'
  resources :musicians
end
