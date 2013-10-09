VulcainApi::Application.routes.draw do

  resource :orders, :only => [:create]
  resource :answers, :only => [:create]
  
  namespace :admin do
    resources :monitors, :only => [:index, :show, :create]
    resources :logs, :only => [:show, :index]
  end

end
