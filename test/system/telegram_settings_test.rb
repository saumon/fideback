require "test_helper"
require "application_system_test_case"

class TelegramSettingsSystemTest < ApplicationSystemTestCase
  setup do
    visit new_manager_session_path
    fill_in "E-mail", with: "alice@example.com"
    fill_in "Mot de passe", with: "password123"
    click_on "Connexion", match: :first
    assert_selector "h1", text: "Mes campagnes"
    click_on "Alice Manager"
    assert_selector "#telegram-settings"
  end

  test "the manager links a bot, detects the chat, turns notifications on and sends a test message" do
    fake_telegram.respond("getUpdates", result: [ FakeTelegram.private_update(update_id: 1, chat_id: 4242, first_name: "Alice", username: "alice_m") ])
    assert_selector "details.telegram-guide[open]"
    assert_text "Relier votre bot en 6 étapes"

    fill_in "Token du bot", with: TELEGRAM_TOKEN
    click_on "Détecter"

    assert_text "Conversation trouvée : Alice (@alice_m)"
    assert_field "Identifiant de conversation", with: "4242"
    assert_nil managers(:alice).reload.telegram_chat_id

    find("label", text: "Envoyer mes notifications sur Telegram").click
    click_on "Enregistrer"

    assert_text "Notifications Telegram activées."
    assert_selector ".telegram-state", text: "Activées"
    assert_selector ".telegram-token-hint", text: "••••1234"
    assert_selector "details.telegram-guide:not([open])"
    assert managers(:alice).reload.telegram_active?

    click_on "Envoyer un message de test"

    assert_text "Message de test envoyé : regardez dans Telegram."
    assert_equal "4242", fake_telegram.sent_messages.sole["chat_id"]
  end

  test "an invalid chat id is refused in place" do
    fill_in "Token du bot", with: TELEGRAM_TOKEN
    fill_in "Identifiant de conversation", with: "@alice"
    click_on "Enregistrer"

    assert_text "L'identifiant de conversation doit être numérique"
    assert_nil managers(:alice).reload.telegram_bot_token
  end
end
