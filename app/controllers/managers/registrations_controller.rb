# Inscription. Devise garde la création et la validation du compte ; seul
# l'endroit où l'on envoie la personne ensuite est propre à l'application.
class Managers::RegistrationsController < Devise::RegistrationsController
  # Après require_no_authentication, que Devise place en tête : un manager déjà connecté garde sa réponse habituelle.
  before_action :require_open_registrations, only: %i[new create]

  protected

  # Inscriptions fermées par l'Admin : la page et l'envoi du formulaire répondent pareil, par un avertissement
  # sur l'accueil. Tant qu'aucun manager n'existe, elles restent possibles : le premier compte devient Admin.
  # Les boutons « Créer un compte » ne sont pas masqués, c'est cette garde qui répond.
  def require_open_registrations
    return if Setting.registrations_open? || Manager.none?

    redirect_to root_path, flash: { warning: "Les inscriptions sont fermées pour le moment." }, status: :see_other
  end

  # L'inscription crée un compte inactif et n'ouvre pas de session. Le défaut de
  # Devise est root_path, que l'authentification renverrait vers la connexion
  # avec un « veuillez vous connecter » qui remplacerait le message « consultez
  # votre boîte mail ».
  def after_inactive_sign_up_path_for(_resource)
    new_manager_session_path
  end
end
