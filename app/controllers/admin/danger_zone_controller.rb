# Actions à risque réservées à l'Admin. Pour l'instant : ouvrir ou fermer les inscriptions.
class Admin::DangerZoneController < Admin::BaseController
  def show
    @registrations_open = Setting.registrations_open?
    # La confirmation est rendue par le serveur (?confirm=1), pour fonctionner sans JavaScript.
    @confirming = @registrations_open && params[:confirm].present?
  end

  # Seules les valeurs explicites « true » ou « false » sont acceptées : une requête sans valeur ne ferme rien.
  def update
    value = params[:registrations_open]
    return head :unprocessable_content unless %w[true false].include?(value)

    open = value == "true"
    Setting.registrations_open = open
    redirect_to admin_danger_zone_path, notice: open ? "Les inscriptions sont réactivées." : "Les inscriptions sont désactivées."
  end
end
