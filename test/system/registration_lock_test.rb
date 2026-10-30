require "test_helper"
require "application_system_test_case"

class RegistrationLockTest < ApplicationSystemTestCase
  setup { Setting.registrations_open = false }

  test "clicking Créer un compte while registrations are closed shows a warning toast on the home page" do
    visit root_path
    click_on "Créer un compte", match: :first

    assert_selector ".toast.flash-warning", text: "Les inscriptions sont fermées pour le moment."
    assert_equal root_path, page.current_path
    assert_selector ".home-hero"
  end

  test "a warning stays longer than a notice with the same text" do
    visit root_path
    click_on "Créer un compte", match: :first
    assert_selector ".toast.flash-warning.is-timed"

    text = find(".toast.flash-warning p").text
    warning = page.evaluate_script("parseFloat(document.querySelector('.toast.flash-warning').style.getPropertyValue('--toast-duration'))")
    notice = [ [ 3000 + 60 * text.length, 4000 ].max, 10000 ].min
    assert_equal notice + 2000, warning
  end

  test "an admin closes registrations from the danger zone, then a visitor is turned away" do
    Setting.registrations_open = true
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"

    click_on "Administration"
    click_on "Danger zone"
    assert_selector ".status-open", text: "Ouvertes"
    click_on "Désactiver les inscriptions"
    assert_selector ".zone-confirm"
    within(".zone-confirm") { click_on "Désactiver les inscriptions" }

    assert_selector ".toast.flash-notice", text: "Les inscriptions sont désactivées."
    assert_selector ".status-closed", text: "Fermées"
    assert_not Setting.registrations_open?
  end
end
