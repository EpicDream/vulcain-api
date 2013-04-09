Vulcain::Application.routes.draw do
  resource :orders, :only => [:create]
  resource :payments, :only => [:create]
end
