require "test_helper"

class NotFoundPageTest < ActionDispatch::IntegrationTest
  # Le test local affiche la page de débogage de Rails ; ici on veut la page vue par un visiteur.
  setup { Rails.application.env_config["action_dispatch.show_detailed_exceptions"] = false }
  teardown { Rails.application.env_config.delete("action_dispatch.show_detailed_exceptions") }

  test "an unknown address answers 404 with the site's own page" do
    get "/nulle-part"

    assert_response :not_found
    assert_select "header.site-header"
    assert_select "link[rel=stylesheet]"
    assert_select "h1", /introuvable/
  end

  test "the page says 404, is announced once, and keeps decoration out of reach of screen readers" do
    get "/nulle-part"

    assert_select ".not-found-code", "Erreur 404"
    assert_select "title", /404/
    assert_select "h1 .visually-hidden", "Cette page est introuvable."
    assert_select "h1 [aria-hidden=true]"
    assert_select ".not-found-digits[aria-hidden=true]"
    assert_select ".not-found .track[aria-hidden=true]"
  end

  test "the way back leads home for a visitor and to the campaigns for a manager" do
    get "/nulle-part"
    assert_select ".not-found a.btn[href=?]", root_path, text: "Retour à l'accueil"

    sign_in managers(:bob)
    get "/nulle-part"
    assert_select ".not-found a.btn[href=?]", campaigns_path, text: "Retour à mes campagnes"
  end

  test "the respondent area gets the page without account links" do
    get "/repondre/inconnu/nulle-part"

    assert_response :not_found
    assert_select ".not-found"
    assert_select "header.site-header a", false
    assert_select "a", text: "Créer un compte", count: 0
    assert_select "a", text: "Se connecter", count: 0
  end

  test "an unknown personal link behaves as if the page did not exist" do
    get respondent_form_path(token: "inconnu")

    assert_response :not_found
    assert_select ".not-found"
    assert_select "header.site-header a", false
  end

  test "an unknown address with another format gets the same html page" do
    get "/nulle-part.json"

    assert_response :not_found
    assert_equal "text/html", response.media_type
    assert_select "h1", /introuvable/
  end

  test "an unknown address answers 404 to any method" do
    post "/nulle-part"

    assert_response :not_found
    assert_select "h1", /introuvable/
  end

  test "a missing record answers 404 with the same page" do
    sign_in managers(:alice)

    get campaign_path(id: 0)

    assert_response :not_found
    assert_select "h1", /introuvable/
  end

  test "a signed-in manager keeps the manager's navigation on a 404" do
    sign_in managers(:bob)

    get "/nulle-part"

    assert_response :not_found
    assert_select "nav a", text: "Mes campagnes"
    assert_select "nav a", text: "Créer un compte", count: 0
  end

  test "a manager who is not an admin gets the same page on the administration" do
    sign_in managers(:bob)

    get admin_root_path

    assert_response :not_found
    assert_select "header.site-header"
    assert_select "h1", /introuvable/
  end

  test "the static page takes over when the dressed page cannot be rendered" do
    ErrorsController.define_singleton_method(:new) { |*| raise "rendu impossible" }
    begin
      get "/nulle-part"
    ensure
      ErrorsController.singleton_class.remove_method(:new)
    end

    assert_response :not_found
    assert_select "h1", "Cette page n'existe pas."
  end

  test "other errors keep their static page" do
    env = Rack::MockRequest.env_for("/x").merge("PATH_INFO" => "/422")
    status, _headers, body = Rails.application.config.exceptions_app.call(env)

    assert_equal 422, status
    assert_includes body.each.to_a.join, "422"
  end
end
