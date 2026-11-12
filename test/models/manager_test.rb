require "test_helper"

class ManagerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "the first manager created is an admin, the next ones are managers" do
    Manager.destroy_all

    first = Manager.create!(name: "First", email: "first@example.com", password: "password123")
    second = Manager.create!(name: "Second", email: "second@example.com", password: "password123")

    assert first.reload.admin?
    assert second.reload.manager?
  end

  test "nobody becomes admin after the admin is gone" do
    Manager.destroy_all
    admin = Manager.create!(name: "First", email: "first@example.com", password: "password123")
    Manager.create!(name: "Second", email: "second@example.com", password: "password123")
    admin.destroy
    third = Manager.create!(name: "Third", email: "third@example.com", password: "password123")

    assert third.manager?
    assert_equal 0, Manager.admin.count
  end

  test "a manager created while others exist is a manager" do
    assert Manager.create!(name: "New", email: "new@example.com", password: "password123").manager?
  end

  test "requires a name" do
    manager = Manager.new(email: "c@example.com", password: "password123")
    assert_not manager.valid?
    assert manager.errors.of_kind?(:name, :blank)
  end

  test "email must be unique" do
    manager = Manager.new(name: "Dup", email: managers(:alice).email, password: "password123")
    assert_not manager.valid?
  end

  test "a new manager is inactive until confirmed" do
    manager = Manager.create!(name: "New", email: "new@example.com", password: "password123")
    assert_not manager.confirmed?
    assert_not manager.active_for_authentication?
  end

  test "resend_activation! issues a fresh token and invalidates the previous one" do
    manager = Manager.create!(name: "New", email: "new@example.com", password: "password123")
    first_token = manager.instance_variable_get(:@raw_confirmation_token)

    assert_emails 1 do
      manager.resend_activation!
    end
    second_token = manager.instance_variable_get(:@raw_confirmation_token)

    assert_not_equal first_token, second_token
    assert_nil Manager.confirm_by_token(first_token).confirmed_at
    assert Manager.confirm_by_token(second_token).confirmed?
  end

  test "two new contacts with the same email in one submission are refused, the second one flagged" do
    manager = managers(:alice)
    saved = manager.update(contacts_attributes: {
      "1" => { name: "Nina", email: "nina@example.com", managed: "1" },
      "2" => { name: "Nina bis", email: "NINA@example.com", surveyable: "1" }
    })
    assert_not saved
    first, second = manager.contacts.select(&:new_record?)
    assert_empty first.errors[:email]
    assert second.errors.of_kind?(:email, :taken)
    assert_not Contact.exists?(email: "nina@example.com")
  end

  test "contact rows without name nor email are ignored" do
    assert_no_difference "Contact.count" do
      assert managers(:alice).update(contacts_attributes: { "1" => { name: "", email: "", managed: "1" } })
    end
  end

  test "telegram notifications are off and unconfigured by default" do
    manager = managers(:bob)

    assert_not manager.telegram_enabled?
    assert_not manager.telegram_configured?
    assert_not manager.telegram_active?
    assert_nil manager.masked_telegram_bot_token
  end

  test "a well-formed telegram configuration is accepted and can be turned on" do
    manager = configure_telegram(managers(:bob))

    assert manager.reload.telegram_active?
    assert_equal TELEGRAM_TOKEN, manager.telegram_bot_token
  end

  test "the bot token is stored encrypted" do
    configure_telegram(managers(:bob))

    raw = Manager.connection.select_value("SELECT telegram_bot_token FROM managers WHERE id = #{managers(:bob).id}")
    assert raw.present?
    assert_not_includes raw, TELEGRAM_TOKEN
    assert_not_includes raw, "AAHfakeToken"
  end

  test "a malformed bot token is refused with a french message" do
    manager = managers(:bob)
    manager.telegram_bot_token = "abc"

    assert_not manager.valid?
    assert_includes manager.errors.full_messages, "Le token du bot n'a pas le format d'un token de bot Telegram"
  end

  test "a non-numeric chat id is refused, a negative one is accepted" do
    manager = managers(:bob)
    manager.telegram_chat_id = "@jdupont"
    assert_not manager.valid?
    assert_includes manager.errors.full_messages, "L'identifiant de conversation doit être numérique"

    manager.telegram_chat_id = "-1001234567890"
    assert manager.valid?
  end

  test "blank telegram values are stored as nil" do
    manager = managers(:bob)
    manager.update!(telegram_bot_token: "  ", telegram_chat_id: "")

    assert_nil manager.reload.telegram_chat_id
    assert_nil manager.telegram_bot_token
  end

  test "notifications cannot be turned on without a token and a chat id" do
    manager = managers(:bob)

    assert_not manager.update(telegram_bot_token: TELEGRAM_TOKEN, telegram_enabled: true)
    assert manager.errors.of_kind?(:telegram_enabled, :incomplete)
    assert_not manager.reload.telegram_enabled?
  end

  test "turning notifications off keeps the configuration" do
    manager = configure_telegram(managers(:bob))
    manager.update!(telegram_enabled: false)

    manager.reload
    assert_not manager.telegram_active?
    assert manager.telegram_configured?
    assert_equal "42", manager.telegram_chat_id
  end

  test "the saved token is only shown by its last four characters" do
    assert_equal "••••1234", configure_telegram(managers(:bob)).masked_telegram_bot_token
  end

  test "a token the current keys cannot decrypt counts as missing and does not block saving the manager" do
    manager = configure_telegram(managers(:bob))
    other_keys = ActiveRecord::Encryption::DerivedSecretKeyProvider.new("a primary key from another deployment")
    foreign = ActiveRecord::Encryption::Encryptor.new.encrypt(TELEGRAM_TOKEN, key_provider: other_keys)
    # Une chaîne SQL : update_all avec un hash passerait par le type chiffré et rechiffrerait la valeur.
    Manager.where(id: manager.id).update_all([ "telegram_bot_token = ?", foreign ])
    manager = Manager.find(manager.id)

    assert_nil manager.readable_telegram_bot_token
    assert_not manager.telegram_configured?
    assert_nil manager.masked_telegram_bot_token
    assert manager.update(name: "Bob Renamed")
  end

  test "destroying a manager destroys their templates but keeps the system one" do
    assert_difference -> { QuestionTemplate.count }, -2 do
      managers(:alice).destroy!
    end
    assert QuestionTemplate.exists?(system: true)
    assert QuestionTemplate.exists?(question_templates(:bob_private).id)
  end
end
