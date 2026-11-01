require "test_helper"
require "application_system_test_case"

class CampaignDeletionTest < ApplicationSystemTestCase
  setup do
    submit_fully(respondents(:rose))
    @campaign = campaigns(:running_campaign)
    @campaign.close!

    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
    visit campaign_path(@campaign)
  end

  test "a manager deletes a closed campaign after a figured confirmation" do
    click_on "Supprimer"
    wait_for_confirm_dialog

    within DIALOG do
      assert_selector "h2", text: "Supprimer cette campagne ?"
      assert_text "La réponse de 1 sondé sur 3 et la synthèse seront perdues. Cette action est définitive."
      assert_selector "button.btn-solid-danger", text: "Supprimer"
    end
    assert_equal "cancel", evaluate_script("document.activeElement.value")

    dismiss_confirm_dialog
    assert Campaign.exists?(@campaign.id)

    click_on "Supprimer"
    accept_confirm_dialog

    assert_selector ".toast", text: "Campagne supprimée."
    assert_selector "h1", text: "Mes campagnes"
    assert_no_selector "a", text: @campaign.name
    assert_not Campaign.exists?(@campaign.id)
  end

  test "the delete button is only on the page of a draft or closed campaign" do
    assert_button "Supprimer"

    reopened = Campaign.find(@campaign.id)
    reopened.update_columns(status: Campaign.statuses[:running])
    visit campaign_path(reopened)

    assert_button "Clôturer la campagne"
    assert_no_button "Supprimer"
  end
end
