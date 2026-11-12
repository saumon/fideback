require "test_helper"
require "application_system_test_case"

class QuestionTemplatePickerTest < ApplicationSystemTestCase
  setup do
    visit new_manager_session_path
    fill_in "E-mail", with: managers(:alice).email
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_text "Mes campagnes"
  end

  def prompts
    all("turbo-frame#questions input[placeholder='Question']").map(&:value)
  end

  test "choosing a template replaces the questions and keeps the rest of the form" do
    visit new_campaign_path
    assert_equal question_templates(:default).items.map(&:prompt), prompts

    fill_in "Nom", with: "Bilans 2026", match: :first
    subject_box = "input[name='campaign[subject_contact_ids][]'][value='#{contacts(:dana).id}']"
    find("label.pick", text: "Dana Managée", match: :first).click
    assert_selector "#{subject_box}:checked", visible: :all

    select "Bilan annuel", from: "Partir d'un modèle"
    assert_selector "input[value='Objectifs atteints']"
    assert_no_selector "input[value='Axes de progrès']"
    assert_equal [ "Objectifs atteints", "Souhaits d'évolution" ], prompts
    assert_equal "Bilans 2026", find_field("Nom", match: :first).value
    assert_selector "#{subject_box}:checked", visible: :all

    # Les questions restent modifiables, et le choix suivant écrase sans confirmation.
    click_on "Ajouter une question"
    all("turbo-frame#questions input[placeholder='Question']").last.set("Ma question")
    select "Fin de projet", from: "Partir d'un modèle"
    assert_selector "input[value='Respect des délais']"
    assert_equal [ "Respect des délais" ], prompts
    assert_equal "Bilans 2026", find_field("Nom", match: :first).value
  end

  test "questions added by hand after choosing a template are saved with the campaign" do
    visit new_campaign_path
    fill_in "Nom", with: "Projet X", match: :first
    select "Fin de projet", from: "Partir d'un modèle"
    assert_selector "input[value='Respect des délais']"
    click_on "Ajouter une question"
    all("turbo-frame#questions input[placeholder='Question']").last.set("Ambiance")
    all("turbo-frame#questions input[type=checkbox][id$=comment]").last.check
    click_on "Créer la campagne"
    assert_text "Campagne créée."
    assert_equal [ "Respect des délais", "Ambiance" ], Campaign.find_by!(name: "Projet X").questions.map(&:prompt)
  end
end
