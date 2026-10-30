Rails.application.routes.draw do
  devise_for :managers, controllers: {
    registrations: "managers/registrations",
    confirmations: "managers/confirmations"
  }

  # Espace réservé à l'Admin du site.
  namespace :admin do
    root "dashboard#show"
    resources :users, only: :index
    resource :danger_zone, path: "danger-zone", controller: "danger_zone", only: %i[show update]
    resources :invitations, only: %i[new create destroy] do
      post :resend, on: :member
    end
  end

  # Acceptation d'une invitation envoyée par l'Admin : lien à jeton, sans compte, ouvert même inscriptions fermées.
  get "invitations/:token", to: "invitation_acceptances#show", as: :invitation_acceptance
  patch "invitations/:token", to: "invitation_acceptances#update"

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

  # Aperçu de la page introuvable, que la page de débogage de Rails masque en développement.
  get "/dev/404", to: "errors#not_found" if Rails.env.development?

  # Page introuvable : Rails relance la requête sur /404 pour toute 404 (config.exceptions_app).
  # Un GET direct sur /404 n'arrive jamais ici : public/404.html le masque.
  match "/404", to: "errors#not_found", via: :all

  get "up" =>"rails/health#show", as: :rails_health_check

  root "pages#home"
end
