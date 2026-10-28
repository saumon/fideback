# Le lien d'activation, et la demande d'un nouvel e-mail d'activation.
#
# Le contrôleur de Devise est gardé pour tout sauf deux points qu'il ne traite
# pas comme voulu : #show dit de quelle façon un lien a échoué, et #create répond
# à l'identique quoi qu'il soit arrivé en limitant chaque adresse à un e-mail
# toutes les cinq minutes.
class Managers::ConfirmationsController < Devise::ConfirmationsController
  # Un e-mail d'activation par adresse et par tranche de cinq minutes.
  RESEND_COOLDOWN = 5.minutes

  # Adresse inconnue, compte déjà actif, demande trop rapprochée ou e-mail
  # envoyé : le visiteur voit la même phrase sur la même page, pour que l'écran
  # ne permette pas de deviner qui a un compte.
  def create
    email = params.dig(resource_name, :email).to_s.strip.downcase
    manager = Manager.find_by(email: email) if email.present?

    if manager && !manager.confirmed? && !throttled?(manager)
      manager.resend_activation!
    end

    redirect_to new_manager_session_path, notice: I18n.t("devise.confirmations.send_paranoid_instructions")
  end

  # Un lien valable active le compte et mène à la connexion, sans jamais
  # connecter la personne. Un lien invalide dit lequel des trois cas il est, sur
  # la page de renvoi qui propose la suite.
  #
  # Le même lien confirme aussi une adresse modifiée, souvent suivi par un
  # manager connecté : il reste alors là où il est plutôt que d'être renvoyé vers
  # la connexion, qui répondrait « déjà connecté ».
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      notice = resource.saved_change_to_email? ? I18n.t("devise.confirmations.email_changed") : I18n.t("devise.confirmations.confirmed")

      redirect_to(signed_in?(resource_name) ? root_path : new_manager_session_path, notice: notice)
    else
      @outcome = failure_outcome(resource)
      render :new, status: :unprocessable_content
    end
  end

  private

  def throttled?(manager)
    manager.confirmation_sent_at.present? && manager.confirmation_sent_at > RESEND_COOLDOWN.ago
  end

  def failure_outcome(record)
    case record.errors.details[:email].pluck(:error)
    in [ *, :confirmation_period_expired, * ] then :expired
    in [ *, :already_confirmed, * ] then :already_active
    else :unrecognised
    end
  end
end
