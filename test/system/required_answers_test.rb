require "test_helper"
require "application_system_test_case"

class RequiredAnswersTest < ApplicationSystemTestCase
  teardown { page.driver.browser.manage.window.resize_to(*SCREEN_SIZE) }

  setup do
    @respondent = respondents(:rose)
    visit respondent_form_path(token: @respondent.token)
    assert_selector ".answer-progress"
  end

  def progress = find(".answer-progress").text
  def rated_inputs = all("input[type=number]")
  def comments = all("textarea")

  # Les champs de Rose : 2 managés, une question à note et commentaire, une à commentaire seul : 2 notes et 4 commentaires.
  def fill_everything(text = "ok")
    rated_inputs.each { |input| input.set(4) }
    comments.each { |area| area.set(text) }
  end

  test "the counter starts at the number of required fields" do
    assert_equal "Il reste 6 champs à renseigner.", progress
    assert_equal 2, rated_inputs.size
    assert_equal 4, comments.size
  end

  test "the counter goes down as comments and notes are filled and up when one is erased" do
    comments.first.set("Bien")
    assert_text "Il reste 5 champs à renseigner."

    rated_inputs.first.set(3)
    assert_text "Il reste 4 champs à renseigner."

    comments.first.set("")
    assert_text "Il reste 5 champs à renseigner."
  end

  test "a comment of spaces does not count as filled" do
    comments.first.set("     ")

    assert_equal "Il reste 6 champs à renseigner.", progress
  end

  test "the rating buttons update the counter" do
    first(".rating-pick[data-rating-value-param='5']").click

    assert_text "Il reste 5 champs à renseigner."
    assert_equal "5", rated_inputs.first.value
  end

  test "the counter says everything is filled and the singular counts the last field" do
    fill_everything
    assert_text "Tout est renseigné : vous pouvez soumettre."

    comments.last.set("")
    assert_text "Il reste 1 champ à renseigner."
  end

  test "a refused submission flags the missing fields, keeps the input and focuses the first one above the actions bar" do
    rated_inputs.each { |input| input.set(4) }
    comments.each_with_index { |area, index| area.set(index.even? ? "Un avis" : "") }

    click_on "Soumettre définitivement"
    accept_confirm_dialog

    assert_selector ".error", text: "Commentaire manquant", count: 2
    assert_selector ".error", text: "Note manquante", count: 0
    assert_text "Il manque 2 champs : complétez ceux qui sont signalés avant de soumettre."
    assert_equal "Il reste 2 champs à renseigner.", progress
    assert_equal "Un avis", comments.first.value
    assert_equal "4", rated_inputs.first.value
    assert_not @respondent.reload.submitted?

    assert_equal "TEXTAREA", evaluate_script("document.activeElement.tagName")
    focused_id = evaluate_script("document.activeElement.id")
    assert_equal "", find("##{focused_id}").value, "le focus n'est pas sur un champ manquant"
    assert_equal comments[1][:id], focused_id, "le focus n'est pas sur le premier champ manquant"
    bottom = evaluate_script("document.activeElement.getBoundingClientRect().bottom")
    bar_top = evaluate_script("document.querySelector('.answer-actions').getBoundingClientRect().top")
    assert_operator bottom, :<=, bar_top, "le champ focalisé est caché par la barre d'actions"
  end

  test "completing the flagged fields and submitting again works, with a one character comment" do
    comments.first.set("ok")
    click_on "Soumettre définitivement"
    accept_confirm_dialog
    assert_selector ".error", minimum: 1

    fill_everything("x")
    click_on "Soumettre définitivement"
    accept_confirm_dialog

    assert_text "Vos réponses ont été soumises"
    assert @respondent.reload.submitted?
  end

  test "saving later accepts missing comments and the counter follows the saved state" do
    rated_inputs.each { |input| input.set(4) }
    click_on "Enregistrer et continuer plus tard"

    assert_text "Vos réponses sont enregistrées."
    assert_equal "Il reste 4 champs à renseigner.", progress
    assert_not @respondent.reload.submitted?
  end

  test "the counter announced after a refusal matches the number of flagged fields" do
    click_on "Soumettre définitivement"
    accept_confirm_dialog

    flagged = all(".error").size
    assert_equal 6, flagged
    assert_equal "Il reste #{flagged} champs à renseigner.", progress
  end

  # Dans une fenêtre courte, le premier champ manquant est hors écran : la page doit défiler jusqu'à lui.
  test "after a refusal the page scrolls so the first missing field is visible above the actions bar" do
    page.driver.browser.manage.window.resize_to(1100, 600)
    visit respondent_form_path(token: @respondent.token)
    rated_inputs.each { |input| input.set(4) }
    comments.each_with_index { |area, index| area.set(index.even? ? "Un avis" : "") }

    click_on "Soumettre définitivement"
    accept_confirm_dialog
    assert_selector ".error", text: "Commentaire manquant", count: 2

    eventually = lambda do |message, &block|
      page.document.synchronize { raise Capybara::ElementNotFound, message unless block.call }
    end
    rect = "(() => { const r = document.activeElement.getBoundingClientRect(); const bar = document.querySelector('.answer-actions').getBoundingClientRect(); return { top: r.top, bottom: r.bottom, barTop: bar.top } })()"
    eventually.call("le champ manquant n'est pas visible") do
      position = evaluate_script(rect)
      position["top"] >= 0 && position["bottom"] <= position["barTop"]
    end
    assert_equal comments[1][:id], evaluate_script("document.activeElement.id")
  end
end
