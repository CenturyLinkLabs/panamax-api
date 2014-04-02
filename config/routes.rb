PanamaxApi::Application.routes.draw do
  get '/search', to: 'search#index'

  get 'repositories/*repository/tags', to: 'repositories#list_tags'
end
