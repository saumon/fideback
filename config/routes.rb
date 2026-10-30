Rails.application.routes.draw do
  devise_for :managers, controllers: {
    registrations: "managers/registrations",
    confirmations: "managers/confirmations"
  }

  # Annuaire du manager : managés et sondables réutilisés d'une campagne à l'autre.
  resource :team, only: %i[show update]

  resources :campaigns do
    member do
      post :launch
      post :close
    end
    resources :summaries, only: :show, param: :subject_id
    resources :respondents, only: [] do
      post :resend, on: :member
    end
  end

  # Espace sondé : accès par lien personnel à jeton, sans compte.
  scope "repondre/:token", controller: :respondent_forms do
    get "/", action: :show, as: :respondent_form
    patch "/", action: :update
    post "soumettre", action: :submit, as: :submit_respondent_form
  end

  # Boîte mail de développement : les emails interceptés par letter_opener_web.
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get "up" =>"rails/health#show", as: :rails_health_check

  root "pages#home"
end
