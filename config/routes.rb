PanamaxApi::Application.routes.draw do
  get '/search', to: 'search#index'
end
