Rails.application.routes.draw do
  resources :logos
    root 'logos#index'
  # get '/show' => 'logos#show'
  # post '/show' => 'logos#index'
  post '/upload' => 'logos#new'
  get '/upload' => 'logos#new'

  # post '/convert' => 'logos#convert'
  get '/convert' => 'logos#convert'
  get '/manipulate' => 'logos#manipulate'
end
