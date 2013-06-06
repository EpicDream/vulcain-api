VulcainApi::Application.routes.draw do
  # PLUGIN
  get "plugin/strategies/actions"
  post "plugin/strategies/create"
  get "plugin/strategies/show"
  post "plugin/strategies/test"

  resource :orders, :only => [:create]
  resource :answers, :only => [:create]
  namespace :admin do
    resources :monitors, :only => [:index, :show, :create]
    resources :logs, :only => [:show, :index]
  end
end
