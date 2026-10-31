# Actions à risque réservées à l'Admin : ouvrir ou fermer les inscriptions, exiger ou non la connexion par lien unique.
class Admin::DangerZoneController < Admin::BaseController
  def show
    @registrations_open = Setting.registrations_open?
    @login_link_required = Setting.login_link_required?
    # Les confirmations sont rendues par le serveur (?confirm=registrations ou ?confirm=login_link), pour fonctionner
    # sans JavaScript. On ne confirme que ce qui restreint : fermer les inscriptions, exiger le lien.
    @confirming_registrations = @registrations_open && params[:confirm] == "registrations"
    @confirming_login_link = !@login_link_required && params[:confirm] == "login_link"
  end

  # Un seul réglage par requête, et seules les valeurs explicites « true » ou « false » sont acceptées : une
  # requête sans valeur ne change rien.
  def update
    if params.key?(:registrations_open)
      value = params[:registrations_open]
      return head :unprocessable_content unless %w[true false].include?(value)

      open = value == "true"
      Setting.registrations_open = open
      notice = open ? "Les inscriptions sont réactivées." : "Les inscriptions sont désactivées."
    elsif params.key?(:login_link_required)
      value = params[:login_link_required]
      return head :unprocessable_content unless %w[true false].include?(value)

      required = value == "true"
      Setting.login_link_required = required
      notice = required ? "La connexion par lien unique est activée." : "La connexion par lien unique est désactivée."
    else
      return head :unprocessable_content
    end

    redirect_to admin_danger_zone_path, notice: notice
  end
end
