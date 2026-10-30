require "test_helper"
require "application_system_test_case"

class ManagerInvitationTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  test "an admin invites a manager while registrations are closed, who accepts and signs in" do
    Setting.registrations_open = false
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"

    click_on "Administration"
    click_on "Utilisateurs"
    click_on "Inviter un manager"
    fill_in "Nom", with: "Pat Durand"
    fill_in "E-mail", with: "pat@example.com"
    perform_enqueued_jobs do
      click_on "Envoyer l'invitation"
      assert_selector ".toast.flash-notice", text: "Invitation envoyée à pat@example.com."
    end
    assert_selector "#invitations-title ~ .table-scroll", text: "Pat Durand"
    assert_selector ".status-pending", text: "En attente"

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "pat@example.com" ], mail.to
    link = mail.html_part.body.to_s[/href="([^"]*\/invitations\/[^"]*)"/, 1]
    click_on "Se déconnecter"

    visit URI(CGI.unescapeHTML(link)).request_uri # le lien pointe vers l'hôte du mailer, pas vers le serveur de test
    assert_selector "h2", text: "Bienvenue"
    assert_field "E-mail", with: "pat@example.com", readonly: true
    fill_in "Mot de passe", with: "password123", match: :prefer_exact
    fill_in "Confirmation du mot de passe", with: "password123"
    click_on "Créer mon compte"

    assert_selector ".toast.flash-notice", text: "Votre compte est créé."
    assert_selector "h2", text: "Connexion"
    fill_in "E-mail", with: "pat@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"

    visit URI(CGI.unescapeHTML(link)).request_uri
    assert_text "Vous êtes déjà connecté(e)."
  end
end
