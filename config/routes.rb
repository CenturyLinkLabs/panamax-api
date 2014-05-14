PanamaxApi::Application.routes.draw do
  get '/search', to: 'search#index'

  get 'repositories/*repository/tags', to: 'repositories#list_tags'

  resources :templates, only: [:index, :show]
  resources :apps, only: [:index, :show, :create, :destroy] do
    resources :services, only: [:index, :show, :create, :update, :destroy] do
      member do
        get :journal
        post :start
      end
    end
  end
end
