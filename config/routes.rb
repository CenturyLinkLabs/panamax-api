PanamaxApi::Application.routes.draw do
  get '/search', to: 'search#index'

  get 'repositories/*repository/tags', to: 'repositories#list_tags'

  resources :templates, only: [:index, :show, :create, :destroy] do
    member do
      post :save
    end
  end
  resources :apps, only: [:index, :show, :create, :update, :destroy] do
    member do
      get :journal
      put :rebuild
      post :template
    end

    resources :categories, only: [:index, :show, :create, :update, :destroy]

    resources :services, only: [:index, :show, :create, :update, :destroy] do
      member do
        get :journal
      end
    end
  end

  resources :types, only: [:index]

  resources :template_repos, only: [:index, :create]
  resource :user, only: [:show, :update]
  resource :panamax, only: [:show]
end
