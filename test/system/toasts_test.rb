require "test_helper"
require "application_system_test_case"

class ToastsTest < ApplicationSystemTestCase
  setup do
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes" # la session existe avant toute autre visite
  end

  test "a notice shows up as a toast and leaves on its own" do
    assert_selector ".toasts .toast.flash-notice"
    assert_no_selector ".toast", wait: 12
  end

  test "an alert stays until it is closed" do
    campaign = campaigns(:running_campaign)
    visit campaign_path(campaign)
    respondents(:rose).update!(submitted_at: Time.current) # refusé entre l'affichage du bouton et le clic
    within("tr", text: "Rose Sondée") { click_on "Renvoyer" }
    accept_confirm_dialog

    assert_selector ".toast.flash-alert[role=alert]", text: "Rose Sondée"
    sleep 11 # au-delà de la durée maximale d'une notice
    assert_selector ".toast.flash-alert"
    find("button[aria-label='Fermer la notification']").click
    assert_no_selector ".toast.flash-alert"
  end

  test "a toast is not shown again when coming back through history" do
    visit campaign_path(campaigns(:running_campaign))
    click_on "Clôturer la campagne"
    accept_confirm_dialog
    assert_selector ".toast", text: "Campagne clôturée."
    click_on "Mes campagnes", match: :first
    assert_selector "h1", text: "Mes campagnes"
    go_back
    assert_selector "h1", text: "Campagne en cours"
    assert_no_selector ".toast", text: "Campagne clôturée."
  end
end
