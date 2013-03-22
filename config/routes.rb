Vulcain::Application.routes.draw do
  resource :orders, :only => [:create]
end
