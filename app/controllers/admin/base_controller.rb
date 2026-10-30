# Garde de l'espace d'administration : l'authentification est celle de
# l'application, puis tout manager qui n'est pas Admin reçoit un 404 plutôt
# qu'un refus, pour que la page ne révèle pas son existence.
class Admin::BaseController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    raise ActionController::RoutingError, "Not Found" unless current_manager.admin?
  end
end
