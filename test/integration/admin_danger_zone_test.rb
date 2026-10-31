require "test_helper"

class AdminDangerZoneTest < ActionDispatch::IntegrationTest
  test "an admin sees the screen, with registrations open by default" do
    sign_in managers(:alice)

    get admin_danger_zone_path

    assert_response :success
    assert_select "h1", "Danger zone"
    assert_select ".status-open", "Ouvertes"
    assert_select "main a[href=?]", admin_root_path
    assert_select "a.btn-danger[href=?]", admin_danger_zone_path(confirm: "registrations"), text: "Désactiver les inscriptions"
  end

  test "a manager who is not an admin gets a 404 and cannot change the setting" do
    sign_in managers(:bob)

    get admin_danger_zone_path
    assert_response :not_found

    patch admin_danger_zone_path, params: { registrations_open: "false" }
    assert_response :not_found
    assert Setting.registrations_open?
  end

  test "a visitor is sent to the sign-in page" do
    get admin_danger_zone_path
    assert_redirected_to new_manager_session_path

    patch admin_danger_zone_path, params: { registrations_open: "false" }
    assert_redirected_to new_manager_session_path
    assert Setting.registrations_open?
  end

  test "asking to deactivate shows the confirmation without changing anything" do
    sign_in managers(:alice)

    get admin_danger_zone_path(confirm: "registrations")

    assert_response :success
    assert_select ".zone-confirm", text: /comptes existants ne changent pas/
    assert_select ".zone-confirm form button", "Désactiver les inscriptions"
    assert_select ".zone-confirm a[href=?]", admin_danger_zone_path, text: "Annuler"
    assert Setting.registrations_open?
  end

  test "cancelling leaves registrations open" do
    sign_in managers(:alice)

    get admin_danger_zone_path

    assert_select ".zone-confirm", false
    assert_select ".status-open"
  end

  test "confirming closes registrations and says so" do
    sign_in managers(:alice)

    patch admin_danger_zone_path, params: { registrations_open: "false" }

    assert_redirected_to admin_danger_zone_path
    assert_equal "Les inscriptions sont désactivées.", flash[:notice]
    assert_not Setting.registrations_open?

    follow_redirect!
    assert_select ".status-closed", "Fermées"
    assert_select "main form button", "Réactiver les inscriptions"
    assert_select "a", text: "Désactiver les inscriptions", count: 0
  end

  test "reactivating opens registrations again without confirmation" do
    Setting.registrations_open = false
    sign_in managers(:alice)

    patch admin_danger_zone_path, params: { registrations_open: "true" }

    assert_redirected_to admin_danger_zone_path
    assert_equal "Les inscriptions sont réactivées.", flash[:notice]
    assert Setting.registrations_open?
  end

  test "a request without an explicit value closes nothing" do
    sign_in managers(:alice)

    patch admin_danger_zone_path
    assert_response :unprocessable_content
    patch admin_danger_zone_path, params: { registrations_open: "maybe" }
    assert_response :unprocessable_content
    assert Setting.registrations_open?
  end

  test "the confirmation is not offered when registrations are already closed" do
    Setting.registrations_open = false
    sign_in managers(:alice)

    get admin_danger_zone_path(confirm: "registrations")

    assert_select ".zone-confirm", false
  end

  test "the administration screen links to the danger zone" do
    sign_in managers(:alice)

    get admin_root_path

    assert_select "main a.btn[href=?]", admin_danger_zone_path, text: "Danger zone"
  end

  test "the danger zone keeps Administration highlighted in the menu" do
    sign_in managers(:alice)

    get admin_danger_zone_path

    assert_equal [ "Administration" ], css_select("header nav a[aria-current]").map(&:text)
  end

  test "the login link block shows the option off by default, with the rule of the link" do
    sign_in managers(:alice)

    get admin_danger_zone_path

    assert_select "#login-link-title", "Connexion par lien unique"
    assert_select "section[aria-labelledby=login-link-title] .status-open", "Désactivée"
    assert_select "section[aria-labelledby=login-link-title] .zone-note", /10 minutes et ne sert qu'une fois/
    assert_select "a.btn-danger[href=?]", admin_danger_zone_path(confirm: "login_link"), text: "Activer la connexion par lien"
  end

  test "asking to activate the login link shows the warnings without changing anything" do
    sign_in managers(:alice)

    get admin_danger_zone_path(confirm: "login_link")

    assert_response :success
    assert_select ".zone-confirm", text: /plus personne ne pourra se connecter/
    assert_select ".zone-confirm", text: /sessions déjà ouvertes restent valables/
    assert_select ".zone-confirm", text: /Se souvenir de moi/
    assert_select ".zone-confirm form button", "Activer la connexion par lien"
    assert_select ".zone-confirm a[href=?]", admin_danger_zone_path, text: "Annuler"
    assert_not Setting.login_link_required?
  end

  test "the confirmations of the two settings do not mix" do
    sign_in managers(:alice)

    get admin_danger_zone_path(confirm: "login_link")
    assert_select ".zone-confirm", count: 1
    assert_select "section[aria-labelledby=registrations-title] .zone-confirm", false

    get admin_danger_zone_path(confirm: "registrations")
    assert_select ".zone-confirm", count: 1
    assert_select "section[aria-labelledby=login-link-title] .zone-confirm", false
  end

  test "activating the login link says so and shows the option on" do
    sign_in managers(:alice)

    patch admin_danger_zone_path, params: { login_link_required: "true" }

    assert_redirected_to admin_danger_zone_path
    assert_equal "La connexion par lien unique est activée.", flash[:notice]
    assert Setting.login_link_required?

    follow_redirect!
    assert_select "section[aria-labelledby=login-link-title] .status-closed", "Activée"
    assert_select "section[aria-labelledby=login-link-title] form button", "Désactiver la connexion par lien"
  end

  test "deactivating the login link needs no confirmation" do
    Setting.login_link_required = true
    sign_in managers(:alice)

    patch admin_danger_zone_path, params: { login_link_required: "false" }

    assert_redirected_to admin_danger_zone_path
    assert_equal "La connexion par lien unique est désactivée.", flash[:notice]
    assert_not Setting.login_link_required?
  end

  test "the confirmation is not offered when the login link is already required" do
    Setting.login_link_required = true
    sign_in managers(:alice)

    get admin_danger_zone_path(confirm: "login_link")

    assert_select ".zone-confirm", false
  end

  test "the login link setting accepts explicit values only" do
    sign_in managers(:alice)

    patch admin_danger_zone_path, params: { login_link_required: "maybe" }
    assert_response :unprocessable_content
    patch admin_danger_zone_path, params: { login_link_required: "" }
    assert_response :unprocessable_content
    assert_not Setting.login_link_required?
  end

  test "a manager who is not an admin cannot change the login link setting" do
    sign_in managers(:bob)

    patch admin_danger_zone_path, params: { login_link_required: "true" }

    assert_response :not_found
    assert_not Setting.login_link_required?
  end

  test "the two settings change independently" do
    sign_in managers(:alice)

    patch admin_danger_zone_path, params: { login_link_required: "true" }
    patch admin_danger_zone_path, params: { registrations_open: "false" }

    assert Setting.login_link_required?
    assert_not Setting.registrations_open?
  end
end
