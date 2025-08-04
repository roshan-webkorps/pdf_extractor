Rails.application.routes.draw do
  root "documents#index"

  get "/login", to: "sessions#new", as: "new_session"
  post "/login", to: "sessions#create", as: "session"
  delete "/logout", to: "sessions#destroy"

  resources :documents, only: [ :index, :show, :create, :update, :destroy ] do
    member do
      get :download_original
      get :export
    end

    collection do
      get :export_all
      get :export_all_summary
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
