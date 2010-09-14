Dummy::Application.routes.draw do |map|
  match ':controller(/:action(/:id(.:format)))'
end
