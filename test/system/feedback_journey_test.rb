require "test_helper"
require "application_system_test_case"

class FeedbackJourneyTest < ApplicationSystemTestCase
  include ActionMailer::TestHelper

  test "manager launches a campaign, respondents answer, manager reads the named summary" do
    # Inscription du manager
    visit root_path
    click_on "Créer un compte", match: :first
    fill_in "Nom", with: "Claire Manager"
    fill_in "E-mail", with: "claire@example.com"
    fill_in "Mot de passe", with: "password123", match: :prefer_exact
    fill_in "Confirmation du mot de passe", with: "password123"
    click_on "Inscription", match: :first
    assert_text "lien de confirmation vous a été envoyé"

    # Activation par le lien reçu par e-mail, puis connexion
    activation = ActionMailer::Base.deliveries.last
    assert_equal [ "claire@example.com" ], activation.to
    link = activation.html_part.body.to_s[/href="([^"]*confirmation_token[^"]*)"/, 1]
    visit URI(CGI.unescapeHTML(link)).request_uri # le lien pointe vers l'hôte du mailer, pas vers le serveur de test
    assert_text "Votre compte est activé"
    fill_in "E-mail", with: "claire@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_text "Mes campagnes"
    ActionMailer::Base.deliveries.clear # ne garde que les invitations pour la suite

    # Création de la campagne
    click_on "Nouvelle campagne", match: :first
    fill_in "Nom", with: "Entretiens de fin d'année", match: :first
    assert_selector "input[placeholder='Question']", count: 4
    all("button", text: "Supprimer").last.click # retire « Axes de progrès »
    assert_selector "input[placeholder='Question']", count: 3
    click_on "Ajouter une question"
    assert_selector "input[placeholder='Question']", count: 4
    all("input[placeholder='Question']").last.set("Ambiance générale")

    # Annuaire vide : les personnes sont ajoutées depuis la campagne et rejoignent l'équipe
    managers_section = find(:fieldset, "Managés (personnes sur lesquelles porte le feedback)")
    respondents_section = find(:fieldset, "Sondés (personnes interrogées)")
    assert_text "Aucun managé dans votre équipe"
    within(managers_section) do
      click_on "Nouveau contact"
      find("input[placeholder='Nom']").set("Gaspard Managé")
      find("input[placeholder='E-mail']").set("gaspard@example.com")
    end
    within(respondents_section) do
      3.times { click_on "Nouveau contact" }
      names = all("input[placeholder='Nom']")
      emails = all("input[placeholder='E-mail']")
      names[0].set("Rita Sondée"); emails[0].set("rita@example.com")
      names[1].set("Tom Sondé");   emails[1].set("tom@example.com")
      all("button", text: "Supprimer").last.click # ligne laissée vide
      assert_equal 2, all("input[placeholder='Nom']").size
    end
    click_on "Créer la campagne"
    assert_text "Campagne créée."
    created = Campaign.find_by!(name: "Entretiens de fin d'année")
    assert_equal Campaign::DEFAULT_QUESTIONS.first(3).map { |q| q[:prompt] } + [ "Ambiance générale" ], created.questions.map(&:prompt)
    assert_equal 2, created.respondents.count
    assert_text "Gaspard Managé"
    assert_equal [ "Gaspard Managé", "Rita Sondée", "Tom Sondé" ], Manager.find_by!(email: "claire@example.com").contacts.map(&:name)

    # Lancement
    perform_enqueued_jobs do
      click_on "Lancer la campagne"
      accept_confirm_dialog
      assert_text "Campagne lancée"
    end
    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_text "0 / 2 réponses soumises"

    # Les deux sondés répondent via leur lien personnel
    campaign = Campaign.find_by!(name: "Entretiens de fin d'année")
    { "Rita Sondée" => [ 5, "Excellent travail" ], "Tom Sondé" => [ 3, "Peut progresser" ] }.each do |name, (rating, comment)|
      respondent = campaign.respondents.find_by!(name: name)
      using_session(name) do
        visit respondent_form_path(token: respondent.token)
        assert_text "nominativement"
        all("input[type=number]").each { |input| input.set(rating) }
        all("textarea").each { |area| area.set(comment) }
        click_on "Soumettre définitivement"
        accept_confirm_dialog
        assert_text "Vos réponses ont été soumises"
      end
    end

    # La soumission du dernier sondé a clôturé la campagne et prévenu le manager
    assert campaign.reload.closed?
    perform_enqueued_jobs
    completed = ActionMailer::Base.deliveries.last
    assert_equal [ "claire@example.com" ], completed.to
    assert_equal "Tous vos sondés ont répondu : campagne clôturée", completed.subject

    # Le manager consulte la synthèse nominative
    visit campaign_path(campaign)
    assert_text "2 / 2 réponses soumises"
    assert_text "Clôturée : tous les sondés ont répondu."
    click_on "Synthèse"
    assert_text "Synthèse : Gaspard Managé"
    assert_text "Moyenne : 4,0 / 5"
    assert_text "Rita Sondée"
    assert_text "Excellent travail"
    assert_text "Tom Sondé"
    assert_text "Peut progresser"
  end
end
