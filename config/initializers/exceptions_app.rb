# La 404 est rendue par l'application (ErrorsController), dans son habillage ;
# les autres erreurs gardent les pages statiques de public/. Si le rendu de la
# 404 échoue, public/404.html prend le relais : sans cela Rails n'enverrait
# qu'un « 500 Internal Server Error » en texte brut.
static_pages = ActionDispatch::PublicExceptions.new(Rails.public_path)

Rails.application.config.exceptions_app = lambda do |env|
  if env["PATH_INFO"] == "/404"
    begin
      response = Rails.application.routes.call(env)
      next response unless response[1]["x-cascade"] == "pass"
    rescue StandardError => error
      Rails.logger.error("[404] page habillée indisponible, repli statique : #{error.class}: #{error.message}")
    end
  end

  static_pages.call(env)
end
