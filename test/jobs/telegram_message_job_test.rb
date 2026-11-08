require "test_helper"

class TelegramMessageJobTest < ActiveJob::TestCase
  setup { @manager = configure_telegram(managers(:bob)) }

  test "sends the text to the manager's chat with the manager's bot" do
    TelegramMessageJob.perform_now(@manager, "Bonjour")

    request = fake_telegram.requests_to("sendMessage").sole
    assert_equal TELEGRAM_TOKEN, request.token
    assert_equal "42", request.params["chat_id"]
    assert_equal "Bonjour", request.params["text"]
  end

  test "sends nothing when the manager turned telegram off in the meantime" do
    @manager.update!(telegram_enabled: false)

    TelegramMessageJob.perform_now(@manager, "Bonjour")

    assert_empty fake_telegram.requests
  end

  test "rate limiting is retried after the delay Telegram asks for" do
    fake_telegram.respond("sendMessage", status: 429, description: "Too Many Requests: retry after 7", retry_after: 7)

    freeze_time do
      assert_enqueued_with(job: TelegramMessageJob, at: 7.seconds.from_now) do
        TelegramMessageJob.perform_now(@manager, "Bonjour")
      end
    end
  end

  test "server errors and network failures are retried" do
    fake_telegram.respond("sendMessage", status: 502, description: "Bad Gateway")
    assert_enqueued_jobs(1, only: TelegramMessageJob) { TelegramMessageJob.perform_now(@manager, "Bonjour") }

    fake_telegram.respond("sendMessage", raise: Errno::ECONNREFUSED.new)
    assert_enqueued_jobs(1, only: TelegramMessageJob) { TelegramMessageJob.perform_now(@manager, "Bonjour") }
  end

  test "temporary errors stop being retried after the last attempt and are logged" do
    job = TelegramMessageJob.new(@manager, "Bonjour")
    job.executions = TelegramMessageJob::MAX_ATTEMPTS - 1
    fake_telegram.respond("sendMessage", status: 502, description: "Bad Gateway")

    log = capture_log do
      assert_no_enqueued_jobs { job.perform_now }
    end
    assert_includes log, "[telegram] notification au manager #{@manager.id} abandonnée"
  end

  test "a definitive refusal is logged without the token, never retried, and leaves the configuration alone" do
    fake_telegram.respond("sendMessage", status: 403, description: "Forbidden: bot was blocked by the user")

    log = capture_log do
      assert_no_enqueued_jobs { TelegramMessageJob.perform_now(@manager, "Bonjour") }
    end

    assert_includes log, "bot was blocked by the user"
    assert_not_includes log, "AAHfakeToken"
    @manager.reload
    assert @manager.telegram_active?
    assert_equal "42", @manager.telegram_chat_id
  end

  private

  def capture_log
    output = StringIO.new
    original = Rails.logger
    Rails.logger = ActiveSupport::Logger.new(output)
    yield
    output.string
  ensure
    Rails.logger = original
  end
end
