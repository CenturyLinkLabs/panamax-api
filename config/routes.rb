PanamaxApi::Application.routes.draw do
  get '/search', to: 'search#index'

  get 'repositories/*id', to: 'repositories#show'

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

  resources :deployment_targets do
    resources :deployments, controller: :remote_deployments,
                            only: [:index, :show, :create, :destroy] do
        member do
          post :redeploy
        end
      end
    post '/metadata/refresh', to: "remote_metadata_refreshes#create"
  end

  resources :job_templates, only: [:index, :show]

  resources :registries, only: [:create, :destroy, :update, :index, :show]

  resources :local_images, only: [:index, :destroy]
  get 'local_images/*id', to: 'local_images#show'

  resources :types, only: [:index]
  resources :keywords, only: [:index]

  resources :template_repos, only: [:index, :create, :destroy] do
    member do
      post :reload
    end
  end

  resource :user, only: [:show, :update]

  resource :panamax, only: [:show]
end
