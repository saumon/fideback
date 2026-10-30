# Garde de l'espace d'administration : l'authentification est celle de
# l'application, puis tout manager qui n'est pas Admin reçoit la page
# introuvable plutôt qu'un refus, pour que la page ne révèle pas son existence.
# Rendue ici plutôt qu'en levant une erreur : le développement montre alors la
# page vue en production, et non la page de débogage de Rails.
class Admin::BaseController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    render "errors/not_found", status: :not_found unless current_manager.admin?
  end
end
