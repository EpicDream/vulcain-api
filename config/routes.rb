Vulcain::Application.routes.draw do
  resource :orders, :only => [:create]
  resource :answers, :only => [:create]
end
