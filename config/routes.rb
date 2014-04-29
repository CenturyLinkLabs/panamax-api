PanamaxApi::Application.routes.draw do
  get '/search', to: 'search#index'

  get 'repositories/*repository/tags', to: 'repositories#list_tags'

  resources :templates, only: [:index, :show]
  resources :apps, only: [:index, :show, :create, :destroy] do
    resources :services, only: [:index, :show] do
      member do
        get :journal
      end
    end
  end
end
