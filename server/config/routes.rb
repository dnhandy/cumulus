Rails.application.routes.draw do
  resources :jobs, defaults: {format: :json} do
    member do
      get 'results'
      get 'logs'
      patch 'pause'
      patch 'resume'
      patch 'cancel'
    end
  end
  resources :job_files, defaults: {format: :json} do
    collection do
      get 'executables'
      get 'inputs'
    end
    member do
      get 'download'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
