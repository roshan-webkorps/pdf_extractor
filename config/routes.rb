Rails.application.routes.draw do
  root "documents#index"

  resources :documents, only: [ :index, :show, :create, :update, :destroy ] do
    member do
      get :download_original
      get :export
    end

    collection do
      get :export_all
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
