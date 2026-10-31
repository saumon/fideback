# Connexion. Devise garde la vérification du mot de passe et ses messages d'échec ; ce contrôleur n'ajoute que la
# connexion par lien unique, que l'Admin peut exiger de tous. Dans ce cas, le mot de passe seul n'ouvre aucune
# session : la personne attend le lien reçu par e-mail, et c'est le clic qui ouvre la session.
class Managers::SessionsController < Devise::SessionsController
  # Le compte dont le mot de passe vient d'être validé, gardé dans la session Rails le temps d'attendre le lien.
  # Il ne donne accès à rien d'autre qu'à l'écran d'attente et au renvoi.
  PENDING_KEY = :login_link_manager_id

  prepend_before_action :require_no_authentication, only: %i[link resend_link cancel_link open_link]

  def create
    return super unless Setting.login_link_required?

    # store: false authentifie sans écrire la session de Warden : les échecs de Devise (mot de passe incorrect,
    # compte non activé) restent ceux de la connexion habituelle.
    manager = warden.authenticate!(auth_options.merge(store: false))
    session[PENDING_KEY] = manager.id
    LoginLink.issue_for(manager)
    redirect_to manager_login_link_wait_path, status: :see_other
  end

  # Écran « Consultez votre boîte mail ».
  def link
    @manager = pending_manager
    return redirect_to new_manager_session_path unless @manager

    @cooldown = LoginLink.cooldown_remaining(@manager)
  end

  def resend_link
    manager = pending_manager
    return redirect_to new_manager_session_path, status: :see_other unless manager

    if LoginLink.issue_for(manager)
      redirect_to manager_login_link_wait_path, notice: "Un nouveau lien a été envoyé. Le précédent ne fonctionne plus.", status: :see_other
    else
      redirect_to manager_login_link_wait_path, flash: { warning: "Un lien vient d'être envoyé. Patientez une minute avant d'en demander un autre." }, status: :see_other
    end
  end

  # « Changer d'adresse » : on oublie le compte en attente.
  def cancel_link
    session.delete(PENDING_KEY)
    redirect_to new_manager_session_path, status: :see_other
  end

  # Le lien reçu par e-mail. Un lien expiré, déjà utilisé, remplacé ou inconnu répond pareil.
  def open_link
    login_link = LoginLink.find_by(token: params[:token].to_s)

    if login_link&.usable? && login_link.manager.active_for_authentication? && login_link.consume!
      manager = login_link.manager
      sign_in(resource_name, manager)
      session.delete(PENDING_KEY)
      set_flash_message!(:notice, :signed_in)
      redirect_to after_sign_in_path_for(manager)
    else
      render :link_invalid, status: :not_found
    end
  end

  private

  def pending_manager
    return unless Setting.login_link_required?

    manager = Manager.find_by(id: session[PENDING_KEY])
    manager if manager&.active_for_authentication?
  end
end
