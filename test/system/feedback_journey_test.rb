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
    assert_text "Mes campagnes"

    # Création de la campagne
    click_on "Nouvelle campagne", match: :first
    fill_in "Nom", with: "Entretiens de fin d'année", match: :first
    fields = all("input[placeholder='Nom']")
    emails = all("input[placeholder='E-mail']")
    fields[0].set("Gaspard Managé"); emails[0].set("gaspard@example.com")
    fields[3].set("Rita Sondée");    emails[3].set("rita@example.com")
    fields[4].set("Tom Sondé");      emails[4].set("tom@example.com")
    click_on "Créer la campagne"
    assert_text "Campagne créée."
    assert_text "Gaspard Managé"

    # Lancement
    perform_enqueued_jobs do
      accept_confirm { click_on "Lancer la campagne" }
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
        accept_confirm { click_on "Soumettre définitivement" }
        assert_text "Vos réponses ont été soumises"
      end
    end

    # Le manager consulte la synthèse nominative
    visit campaign_path(campaign)
    assert_text "2 / 2 réponses soumises"
    click_on "Synthèse"
    assert_text "Synthèse : Gaspard Managé"
    assert_text "Moyenne : 4,0 / 5"
    assert_text "Rita Sondée"
    assert_text "Excellent travail"
    assert_text "Tom Sondé"
    assert_text "Peut progresser"
  end
end
