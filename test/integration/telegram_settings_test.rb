require "test_helper"

class TelegramSettingsTest < ActionDispatch::IntegrationTest
  def alice = managers(:alice)

  def save(params)
    patch telegram_setting_path, params: { manager: params }
  end

  def detect(params = {})
    patch detect_telegram_setting_path, params: { manager: { telegram_bot_token: "", telegram_chat_id: "" }.merge(params) }, as: :turbo_stream
  end

  # --- Enregistrement ---

  test "saving the telegram settings does not ask for the current password nor touch the account" do
    sign_in alice

    save(telegram_bot_token: TELEGRAM_TOKEN, telegram_chat_id: "42", telegram_enabled: "1")

    assert_redirected_to edit_manager_registration_path
    assert_equal "Notifications Telegram activées.", flash[:notice]
    alice.reload
    assert alice.telegram_active?
    assert_equal TELEGRAM_TOKEN, alice.telegram_bot_token
    assert_equal "Alice Manager", alice.name
    assert_equal "alice@example.com", alice.email
    assert alice.valid_password?("password123")
  end

  test "a blank token field keeps the saved token" do
    configure_telegram(alice)
    sign_in alice

    save(telegram_bot_token: "", telegram_chat_id: "77", telegram_enabled: "1")

    alice.reload
    assert_equal TELEGRAM_TOKEN, alice.telegram_bot_token
    assert_equal "77", alice.telegram_chat_id
  end

  test "turning notifications off keeps the token and the chat id" do
    configure_telegram(alice)
    sign_in alice

    save(telegram_bot_token: "", telegram_chat_id: "42", telegram_enabled: "0")

    assert_equal "Réglages Telegram enregistrés, notifications désactivées.", flash[:notice]
    alice.reload
    assert_not alice.telegram_enabled?
    assert alice.telegram_configured?
  end

  test "invalid settings are refused with french messages and nothing is saved" do
    sign_in alice

    patch telegram_setting_path, params: { manager: { telegram_bot_token: "abc", telegram_chat_id: "@jdupont", telegram_enabled: "1" } },
                                 as: :turbo_stream

    assert_response :unprocessable_entity
    assert_includes response.body, %(target="telegram-settings")
    assert_includes response.body, "Le token du bot n&#39;a pas le format d&#39;un token de bot Telegram"
    assert_includes response.body, "L&#39;identifiant de conversation doit être numérique"
    alice.reload
    assert_nil alice.telegram_bot_token
    assert_not alice.telegram_enabled?
  end

  test "a visitor who is not signed in cannot save telegram settings" do
    save(telegram_bot_token: TELEGRAM_TOKEN, telegram_chat_id: "42", telegram_enabled: "1")

    assert_redirected_to new_manager_session_path
    assert_nil alice.reload.telegram_bot_token
  end

  test "a manager only changes their own telegram settings" do
    configure_telegram(managers(:bob), chat_id: "99")
    sign_in alice

    save(telegram_bot_token: TELEGRAM_TOKEN, telegram_chat_id: "42", telegram_enabled: "1")

    assert_equal "99", managers(:bob).reload.telegram_chat_id
  end

  test "the bot token is filtered from the request logs" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

    filtered = filter.filter("manager" => { "telegram_bot_token" => TELEGRAM_TOKEN, "telegram_chat_id" => "42" })

    assert_equal "[FILTERED]", filtered["manager"]["telegram_bot_token"]
  end

  # --- Détecter ---

  test "detect fills the chat id with the latest private chat and names the person, without saving anything" do
    fake_telegram.respond("getUpdates", result: [ FakeTelegram.private_update(update_id: 1, chat_id: 42, first_name: "Alice", username: "alice_m") ])
    sign_in alice

    detect(telegram_bot_token: TELEGRAM_TOKEN)

    assert_response :success
    assert_includes response.body, %(target="telegram-chat")
    assert_includes response.body, %(value="42")
    assert_includes response.body, "Conversation trouvée : Alice (@alice_m)"
    assert_equal TELEGRAM_TOKEN, fake_telegram.requests_to("getUpdates").sole.token
    alice.reload
    assert_nil alice.telegram_bot_token
    assert_nil alice.telegram_chat_id
  end

  test "detect uses the saved token when the field is left blank" do
    configure_telegram(alice, enabled: false)
    sign_in alice

    detect

    assert_equal TELEGRAM_TOKEN, fake_telegram.requests_to("getMe").sole.token
  end

  test "detect without any token asks for one" do
    sign_in alice

    detect

    assert_includes response.body, "Saisissez d&#39;abord le token de votre bot."
    assert_empty fake_telegram.requests
  end

  test "detect reports a refused token and keeps the typed chat id" do
    fake_telegram.respond("getMe", status: 401, description: "Unauthorized")
    sign_in alice

    detect(telegram_bot_token: TELEGRAM_TOKEN, telegram_chat_id: "555")

    assert_includes response.body, "Token refusé par Telegram"
    assert_includes response.body, %(value="555")
  end

  test "detect without a recent message asks to write to the bot by its username" do
    sign_in alice

    detect(telegram_bot_token: TELEGRAM_TOKEN)

    assert_includes response.body, "écrivez /start à @fideback_test_bot"
  end

  test "detect on a bot behind a webhook explains it and never removes the webhook" do
    fake_telegram.respond("getUpdates", status: 409, description: "Conflict: can't use getUpdates method while webhook is active")
    sign_in alice

    detect(telegram_bot_token: TELEGRAM_TOKEN)

    assert_includes response.body, "Ce bot reçoit déjà ses messages par un webhook"
    assert_includes response.body, "@userinfobot"
    assert_equal %w[getMe getUpdates], fake_telegram.requests.map(&:api_method)
  end

  test "detect reports Telegram being unreachable" do
    fake_telegram.respond("getMe", raise: Net::OpenTimeout.new("execution expired"))
    sign_in alice

    detect(telegram_bot_token: TELEGRAM_TOKEN)

    assert_includes response.body, "Telegram est injoignable pour le moment"
  end

  test "detect is reserved to signed in managers" do
    detect(telegram_bot_token: TELEGRAM_TOKEN)

    assert_redirected_to new_manager_session_path
    assert_empty fake_telegram.requests
  end

  # --- Message de test ---

  test "the test message is sent right away, even when notifications are paused" do
    configure_telegram(alice, enabled: false)
    sign_in alice

    post test_message_telegram_setting_path

    assert_redirected_to edit_manager_registration_path
    assert_equal "Message de test envoyé : regardez dans Telegram.", flash[:notice]
    message = fake_telegram.sent_messages.sole
    assert_equal "42", message["chat_id"]
    assert_includes message["text"], "Fideback est bien relié à ce bot"
  end

  test "a refused test message is reported to the manager" do
    configure_telegram(alice)
    fake_telegram.respond("sendMessage", status: 403, description: "Forbidden: bot was blocked by the user")
    sign_in alice

    post test_message_telegram_setting_path

    assert_redirected_to edit_manager_registration_path
    assert_includes flash[:alert], "vous avez bloqué ce bot ou ne lui avez jamais écrit"
  end

  test "an unknown chat is reported to the manager" do
    configure_telegram(alice)
    fake_telegram.respond("sendMessage", status: 400, description: "Bad Request: chat not found")
    sign_in alice

    post test_message_telegram_setting_path

    assert_includes flash[:alert], "Conversation introuvable"
  end

  test "no test message without a saved configuration" do
    sign_in alice

    post test_message_telegram_setting_path

    assert_equal "Enregistrez d'abord le token du bot et l'identifiant de conversation.", flash[:alert]
    assert_empty fake_telegram.requests
  end

  # --- Rien n'arrive de Telegram, rien d'autre n'y part ---

  test "no route receives anything from Telegram" do
    telegram_routes = Rails.application.routes.routes.select { |route| route.path.spec.to_s.include?("telegram") }

    assert_equal [ "telegram_settings#detect", "telegram_settings#test_message", "telegram_settings#update" ],
                 telegram_routes.map { |route| "#{route.defaults[:controller]}##{route.defaults[:action]}" }.uniq.sort
  end

  test "authentication e-mails never go to Telegram" do
    configure_telegram(alice)

    assert_no_enqueued_jobs(only: TelegramMessageJob) do
      LoginLink.issue_for(alice)
      alice.send_reset_password_instructions
      alice.resend_activation!
    end

    perform_enqueued_jobs
    assert_empty fake_telegram.requests
  end

  # --- Page du compte ---

  test "a manager without telegram sees the section with the guide unfolded and no test button" do
    sign_in alice

    get edit_manager_registration_path

    assert_select "#telegram-settings h3", "Notifications Telegram"
    assert_select "details.telegram-guide[open]" do
      assert_select "summary", "Relier votre bot en 6 étapes"
      assert_select "li", 6
      assert_select "code", text: "/newbot"
      assert_select "a[href='https://telegram.me/BotFather']"
    end
    assert_select ".telegram-guide-note", text: /n8n/
    assert_select ".telegram-state", "À configurer"
    assert_select "button", text: "Envoyer un message de test", count: 0
    assert_select "input[name='manager[telegram_enabled]'][type=checkbox]:not([checked])"
  end

  test "a configured manager sees the guide folded, the masked token and the test button" do
    configure_telegram(alice)
    sign_in alice

    get edit_manager_registration_path

    assert_select "details.telegram-guide:not([open])"
    assert_select ".telegram-token-hint", "••••1234"
    assert_select "input#manager_telegram_bot_token:not([value])"
    assert_select "input#manager_telegram_chat_id[value='42']"
    assert_select ".telegram-state", "Activées"
    assert_select "button", text: "Envoyer un message de test"
    assert_select "input[name='manager[telegram_enabled]'][type=checkbox][checked]"
    assert_not_includes response.body, "AAHfakeToken"
  end

  test "paused notifications are shown as such" do
    configure_telegram(alice, enabled: false)
    sign_in alice

    get edit_manager_registration_path

    assert_select ".telegram-state", "En pause"
  end

  test "the detect button submits the telegram form to detect" do
    sign_in alice

    get edit_manager_registration_path

    assert_select "form#telegram-form[action='#{telegram_setting_path}'] button[formaction='#{detect_telegram_setting_path}']", "Détecter"
  end
end
