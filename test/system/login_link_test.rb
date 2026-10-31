require "test_helper"
require "application_system_test_case"

class LoginLinkSystemTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  test "an admin requires the login link, then a manager signs in through the email" do
    sign_in_with "alice@example.com"
    assert_selector "h1", text: "Mes campagnes"

    click_on "Administration"
    click_on "Danger zone"
    click_on "Activer la connexion par lien"
    assert_text "plus personne ne pourra se connecter"
    click_on "Activer la connexion par lien"
    assert_selector ".toast.flash-notice", text: "La connexion par lien unique est activée."
    click_on "Se déconnecter"
    assert_selector ".toast.flash-notice", text: "Déconnecté(e)."

    visit new_manager_session_path
    assert_no_field "Se souvenir de moi"
    perform_enqueued_jobs do
      fill_in "E-mail", with: "bob@example.com"
      fill_in "Mot de passe", with: "password123"
      click_on "Connexion", match: :first
      assert_selector "h2", text: "Consultez votre boîte mail"
    end
    assert_text "bob@example.com"

    visit campaigns_path
    assert_selector "h2", text: "Connexion"

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "bob@example.com" ], mail.to
    link = mail.html_part.body.to_s[/href="([^"]*\/managers\/sign_in\/link\/[^"]*)"/, 1]
    visit URI(CGI.unescapeHTML(link)).request_uri # le lien pointe vers l'hôte du mailer, pas vers le serveur de test
    assert_selector "h1", text: "Mes campagnes"
    assert_selector ".toast.flash-notice", text: "Connecté(e)."

    click_on "Se déconnecter"
    assert_selector ".toast.flash-notice", text: "Déconnecté(e)."
    visit URI(CGI.unescapeHTML(link)).request_uri
    assert_selector "h2", text: "Lien de connexion invalide"
  end

  test "the resend button counts down and turns on by itself" do
    Setting.login_link_required = true
    visit new_manager_session_path
    fill_in "E-mail", with: "bob@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first

    assert_button "Renvoyer le lien dans", disabled: true
    first = find("button[data-countdown-target=button]").text[/\d+/].to_i
    assert_operator first, :<=, 60
    sleep 1.5
    assert_operator find("button[data-countdown-target=button]").text[/\d+/].to_i, :<, first

    LoginLink.update_all(created_at: 58.seconds.ago)
    visit manager_login_link_wait_path
    assert_button "Renvoyer le lien dans", disabled: true
    assert_button "Renvoyer le lien", exact: true, disabled: false, wait: 5
  end

  private

  def sign_in_with(email)
    visit new_manager_session_path
    fill_in "E-mail", with: email
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
  end
end
