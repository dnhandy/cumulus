Rails.application.routes.draw do
  resources :logs
  resources :results
  resources :output_files
  resources :input_files
  resources :jobs
  resources :job_files
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
