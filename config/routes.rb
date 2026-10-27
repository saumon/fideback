Rails.application.routes.draw do
  devise_for :managers

  resources :campaigns do
    member do
      post :launch
      post :close
    end
    resources :summaries, only: :show, param: :subject_id
  end

  # Espace sondé : accès par lien personnel à jeton, sans compte.
  scope "repondre/:token", controller: :respondent_forms do
    get "/", action: :show, as: :respondent_form
    patch "/", action: :update
    post "soumettre", action: :submit, as: :submit_respondent_form
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
