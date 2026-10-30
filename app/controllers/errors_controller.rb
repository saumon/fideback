# La page « introuvable », rendue dans l'habillage de l'application. Rails la
# demande en relançant la requête sur /404 (config.exceptions_app) ; la même
# adresse permet de la prévisualiser.
class ErrorsController < ApplicationController
  skip_before_action :authenticate_manager!
  # Une 404 peut répondre à un POST venu d'ailleurs : pas de jeton à vérifier.
  skip_forgery_protection

  layout :error_layout

  def not_found
    # Une adresse en .json ou .xml reçoit la même page plutôt qu'une erreur de format.
    render formats: :html, status: :not_found
  end

  private

  # Un sondé n'a pas de compte : la page de l'espace des sondés n'en propose pas.
  def error_layout
    original_path = request.get_header("action_dispatch.original_path").to_s
    original_path.start_with?("/repondre") ? "respondent" : "application"
  end
end
