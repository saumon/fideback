require "test_helper"

class TelegramBotClientTest < ActiveSupport::TestCase
  setup { @client = Telegram::BotClient.new(TELEGRAM_TOKEN) }

  test "getMe calls the bot's endpoint and returns the bot" do
    assert_equal "fideback_test_bot", @client.get_me["username"]

    request = fake_telegram.requests.sole
    assert_equal TELEGRAM_TOKEN, request.token
    assert_equal "getMe", request.api_method
  end

  test "getUpdates neither acknowledges messages nor changes the allowed update types" do
    @client.get_updates

    params = fake_telegram.requests_to("getUpdates").sole.params
    assert_not params.key?("offset")
    assert_not params.key?("allowed_updates")
  end

  test "sendMessage sends HTML text to the chat without link preview" do
    @client.send_message("42", "Bonjour <b>Alice</b>")

    params = fake_telegram.sent_messages.sole
    assert_equal "42", params["chat_id"]
    assert_equal "Bonjour <b>Alice</b>", params["text"]
    assert_equal "HTML", params["parse_mode"]
    assert_equal({ "is_disabled" => true }, params["link_preview_options"])
  end

  test "a refused token raises an unauthorized, definitive error" do
    fake_telegram.respond("getMe", status: 401, description: "Unauthorized")

    error = assert_raises(Telegram::BotClient::Error) { @client.get_me }
    assert error.unauthorized?
    assert_not error.temporary?
    assert_equal "Unauthorized", error.description
  end

  test "a bot behind a webhook raises a conflict error" do
    fake_telegram.respond("getUpdates", status: 409, description: "Conflict: can't use getUpdates method while webhook is active")

    assert assert_raises(Telegram::BotClient::Error) { @client.get_updates }.webhook_conflict?
  end

  test "rate limiting is temporary and carries the delay asked by Telegram" do
    fake_telegram.respond("sendMessage", status: 429, description: "Too Many Requests: retry after 7", retry_after: 7)

    error = assert_raises(Telegram::BotClient::Error) { @client.send_message("42", "x") }
    assert error.temporary?
    assert_equal 7, error.retry_after
  end

  test "server errors and network failures are temporary" do
    fake_telegram.respond("sendMessage", status: 502, description: "Bad Gateway")
    assert assert_raises(Telegram::BotClient::Error) { @client.send_message("42", "x") }.temporary?

    fake_telegram.respond("sendMessage", raise: Net::OpenTimeout.new("execution expired"))
    error = assert_raises(Telegram::BotClient::Error) { @client.send_message("42", "x") }
    assert error.temporary?
    assert_nil error.status
  end

  test "a blocked bot is a definitive error" do
    fake_telegram.respond("sendMessage", status: 403, description: "Forbidden: bot was blocked by the user")

    assert_not assert_raises(Telegram::BotClient::Error) { @client.send_message("42", "x") }.temporary?
  end

  test "no update means no chat" do
    assert_nil Telegram::BotClient.latest_private_chat([])
    assert_nil Telegram::BotClient.latest_private_chat(nil)
  end

  test "group messages are ignored" do
    updates = [ FakeTelegram.group_update(update_id: 1, chat_id: -100, title: "L'équipe") ]

    assert_nil Telegram::BotClient.latest_private_chat(updates)
  end

  test "the most recent private chat wins" do
    now = Time.current.to_i
    updates = [
      FakeTelegram.private_update(update_id: 1, chat_id: 11, first_name: "Ancien", date: now - 60),
      FakeTelegram.private_update(update_id: 2, chat_id: 42, first_name: "Jean", username: "jdupont", date: now),
      FakeTelegram.group_update(update_id: 3, chat_id: -100, title: "L'équipe", date: now + 10),
      { "update_id" => 4, "edited_message" => { "chat" => { "id" => 99, "type" => "private" }, "date" => now + 20 } }
    ]

    chat = Telegram::BotClient.latest_private_chat(updates)
    assert_equal 42, chat["id"]
    assert_equal "Jean", chat["first_name"]
    assert_equal "jdupont", chat["username"]
  end

  test "the token never shows in errors nor in inspect" do
    fake_telegram.respond("getMe", status: 401, description: "Unauthorized")
    error = assert_raises(Telegram::BotClient::Error) { @client.get_me }

    assert_not_includes error.message, TELEGRAM_TOKEN
    assert_not_includes error.message, "AAHfakeToken"
    assert_not_includes @client.inspect, "AAHfakeToken"
  end
end
