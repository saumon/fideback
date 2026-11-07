require "test_helper"
require "application_system_test_case"

class AdminUserDeletionTest < ApplicationSystemTestCase
  setup do
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
    visit admin_users_path
  end

  test "an admin deletes a manager after a figured confirmation, but cannot delete themselves" do
    within("##{dom_id(managers(:alice))}") { assert_no_button "Supprimer" }

    within("##{dom_id(managers(:bob))}") { click_on "Supprimer" }
    wait_for_confirm_dialog

    within DIALOG do
      assert_selector "h2", text: "Supprimer Bob Manager ?"
      assert_text "Sa campagne et toutes les réponses recueillies seront effacées. Cette action est définitive."
      assert_selector "button.btn-solid-danger", text: "Supprimer"
    end

    dismiss_confirm_dialog
    assert Manager.exists?(managers(:bob).id)

    within("##{dom_id(managers(:bob))}") { click_on "Supprimer" }
    accept_confirm_dialog

    assert_selector ".toast", text: "Bob Manager a été supprimé."
    assert_no_selector "##{dom_id(managers(:bob))}"
    assert_not Manager.exists?(managers(:bob).id)
  end
end
