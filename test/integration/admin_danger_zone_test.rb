require "test_helper"

class AdminDangerZoneTest < ActionDispatch::IntegrationTest
  test "an admin sees the screen, with registrations open by default" do
    sign_in managers(:alice)

    get admin_danger_zone_path

    assert_response :success
    assert_select "h1", "Danger zone"
    assert_select ".status-open", "Ouvertes"
    assert_select "main a[href=?]", admin_root_path
    assert_select "a.btn-danger[href=?]", admin_danger_zone_path(confirm: 1), text: "Désactiver les inscriptions"
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

    get admin_danger_zone_path(confirm: 1)

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

    get admin_danger_zone_path(confirm: 1)

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
end
