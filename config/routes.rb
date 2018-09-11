Rails.application.routes.draw do
  #get 'admin/index'
  #get 'session/new'
  get 'session/create'
  get 'session/destroy'
  resources :users

  get 'admin' => 'admin#index'
  controller :session do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end
  root 'admin#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
