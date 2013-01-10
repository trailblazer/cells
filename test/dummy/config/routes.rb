Dummy::Application.routes.draw do
  get ':controller(/:action(/:id(.:format)))'
  resources :musicians
end
