Vulcain::Application.routes.draw do
  resource :orders, :only => [:create]
  resource :accounts, :only => [:create]
end
