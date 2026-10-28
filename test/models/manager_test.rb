require "test_helper"

class ManagerTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

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
end
