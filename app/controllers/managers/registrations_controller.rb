# Inscription. Devise garde la création et la validation du compte ; seul
# l'endroit où l'on envoie la personne ensuite est propre à l'application.
class Managers::RegistrationsController < Devise::RegistrationsController
  protected

  # L'inscription crée un compte inactif et n'ouvre pas de session. Le défaut de
  # Devise est root_path, que l'authentification renverrait vers la connexion
  # avec un « veuillez vous connecter » qui remplacerait le message « consultez
  # votre boîte mail ».
  def after_inactive_sign_up_path_for(_resource)
    new_manager_session_path
  end
end
