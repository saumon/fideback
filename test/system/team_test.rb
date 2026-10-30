require "test_helper"
require "application_system_test_case"

class TeamTest < ApplicationSystemTestCase
  setup do
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
    click_on "Mon équipe"
    assert_selector "h1", text: "Mon équipe"
  end

  test "the role filter hides rows without dropping them from the save" do
    click_on "Managés"
    assert_selector "input[value='Dana Managée']"
    assert_no_selector "input[value='Rose Sondée']"

    click_on "Ajouter un contact"
    rows = all(".team-row[data-new-record=true]")
    assert_equal 2, rows.size # la ligne vide initiale et la ligne ajoutée restent visibles
    rows.last.find("input[placeholder='Nom']").set("Nina")
    rows.last.find("input[placeholder='E-mail']").set("nina@example.com")
    rows.last.find("label", text: "Sondable").click

    click_on "Enregistrer l'équipe"
    assert_text "Équipe enregistrée."
    assert_equal [ "Dana Managée", "Eli Managé", "Nina", "Rose Sondée", "Sam Sondé" ], managers(:alice).contacts.map(&:name)
    assert contacts(:rose).reload.surveyable?
  end

  test "removing a row then saving deletes the contact" do
    find_field(with: "Sam Sondé").ancestor(".team-row").click_on("Supprimer")
    assert_no_selector "input[value='Sam Sondé']"
    click_on "Enregistrer l'équipe"
    assert_text "Équipe enregistrée."
    assert_not Contact.exists?(name: "Sam Sondé")
  end

  test "check all selects every surveyable contact of the campaign" do
    click_on "Mes campagnes"
    click_on "Nouvelle campagne", match: :first
    fill_in "Nom", with: "Tous sondés", match: :first
    within(:fieldset, "Sondés (personnes interrogées)") do
      assert_no_selector "input[type=checkbox]:checked"
      click_on "Tout cocher"
      assert_selector "input[type=checkbox]:checked", count: 3
    end
    within(:fieldset, "Managés (personnes sur lesquelles porte le feedback)") { assert_no_selector "input[type=checkbox]:checked" }
    click_on "Créer la campagne"
    assert_text "Campagne créée."
    assert_equal [ "Dana Managée", "Rose Sondée", "Sam Sondé" ], Campaign.find_by!(name: "Tous sondés").respondents.order(:name).map(&:name)
  end
end
