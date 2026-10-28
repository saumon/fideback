require "test_helper"

class MailerSettingsTest < ActiveSupport::TestCase
  SETTINGS = Fideback::MailerSettings

  SMTP_ENV = {
    "SMTP_ADDRESS" => "smtp.example.org", "SMTP_PORT" => "587",
    "SMTP_USERNAME" => "mailer", "SMTP_PASSWORD" => "secret"
  }.freeze

  ENV_KEYS = %w[
    SMTP_ADDRESS SMTP_PORT SMTP_DOMAIN SMTP_USERNAME SMTP_PASSWORD SMTP_AUTHENTICATION
    SMTP_ENABLE_STARTTLS_AUTO SMTP_OPENSSL_VERIFY_MODE SMTP_ENABLED SMTP_SENDER MAILER_SENDER
    APP_HOST APP_PORT APP_PROTOCOL
  ].freeze

  # Environnement et credentials maîtrisés : ni .env ni la machine ne comptent.
  def with_settings(env: {}, credentials: {})
    saved = ENV.to_h.slice(*ENV_KEYS)
    ENV_KEYS.each { |key| ENV.delete(key) }
    env.each { |key, value| ENV[key] = value }

    fake = Object.new
    fake.define_singleton_method(:dig) { |*keys| credentials.dig(*keys) }
    Rails.application.define_singleton_method(:credentials) { fake }
    yield
  ensure
    Rails.application.singleton_class.send(:remove_method, :credentials)
    ENV_KEYS.each { |key| ENV.delete(key) }
    saved.each { |key, value| ENV[key] = value }
  end

  test "ENV wins over credentials" do
    with_settings(env: { "SMTP_ADDRESS" => "from-env" }, credentials: { smtp: { address: "from-credentials" } }) do
      assert_equal "from-env", SETTINGS.smtp_settings[:address]
    end
  end

  test "credentials are used when ENV is missing or blank" do
    with_settings(env: { "SMTP_ADDRESS" => "" }, credentials: { smtp: { address: "from-credentials" } }) do
      assert_equal "from-credentials", SETTINGS.smtp_settings[:address]
    end
  end

  test "complete configuration is configured" do
    with_settings(env: SMTP_ENV) do
      assert SETTINGS.smtp_configured?
      assert_equal 587, SETTINGS.smtp_settings[:port]
      assert_equal :plain, SETTINGS.smtp_settings[:authentication]
    end
  end

  test "partial configuration is treated as none" do
    SMTP_ENV.each_key do |missing|
      with_settings(env: SMTP_ENV.except(missing)) do
        assert_not SETTINGS.smtp_configured?, "#{missing} missing should disable SMTP"
      end
    end
  end

  test "SMTP_ENABLED=false switches a complete configuration off" do
    with_settings(env: SMTP_ENV.merge("SMTP_ENABLED" => "false")) do
      assert_not SETTINGS.smtp_enabled?
      assert_not SETTINGS.smtp_configured?
    end
  end

  test "enabled: false in credentials switches SMTP off" do
    with_settings(env: SMTP_ENV, credentials: { smtp: { enabled: false } }) do
      assert_not SETTINGS.smtp_configured?
    end
  end

  test "sender falls back from SMTP_SENDER to MAILER_SENDER to the default" do
    with_settings(env: { "SMTP_SENDER" => "a@example.org", "MAILER_SENDER" => "b@example.org" }) do
      assert_equal "a@example.org", SETTINGS.mailer_sender
    end
    with_settings(env: { "MAILER_SENDER" => "b@example.org" }) do
      assert_equal "b@example.org", SETTINGS.mailer_sender
    end
    with_settings do
      assert_equal SETTINGS::DEFAULT_SENDER, SETTINGS.mailer_sender
    end
  end

  test "default URL options keep the default host and port without APP_HOST" do
    with_settings do
      assert_equal({ host: "localhost", port: 3000, protocol: "http" },
                   SETTINGS.default_url_options(default_host: "localhost", default_port: 3000, default_protocol: "http"))
    end
  end

  test "APP_HOST drops the default port, APP_PORT and APP_PROTOCOL set theirs" do
    with_settings(env: { "APP_HOST" => "192.168.1.23" }) do
      assert_equal({ host: "192.168.1.23", protocol: "http" },
                   SETTINGS.default_url_options(default_host: "localhost", default_port: 3000, default_protocol: "http"))
    end
    with_settings(env: { "APP_HOST" => "fideback.test", "APP_PORT" => "8443", "APP_PROTOCOL" => "https" }) do
      assert_equal({ host: "fideback.test", port: 8443, protocol: "https" },
                   SETTINGS.default_url_options(default_host: "localhost", default_port: 3000, default_protocol: "http"))
    end
  end
end
