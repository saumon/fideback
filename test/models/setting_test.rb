require "test_helper"

class SettingTest < ActiveSupport::TestCase
  test "registrations are open when the setting was never written" do
    assert_empty Setting.all
    assert Setting.registrations_open?
  end

  test "registrations can be closed then reopened, on a single row" do
    Setting.registrations_open = false
    assert_not Setting.registrations_open?

    Setting.registrations_open = true
    assert Setting.registrations_open?
    assert_equal 1, Setting.where(key: "registrations_open").count
  end

  test "a key is unique" do
    Setting.create!(key: "registrations_open", value: "true")

    assert_not Setting.new(key: "registrations_open", value: "false").valid?
  end

  test "the login link is not required when the setting was never written" do
    assert_not Setting.login_link_required?
  end

  test "the login link can be required then dropped, on a single row, apart from registrations" do
    Setting.login_link_required = true
    assert Setting.login_link_required?
    assert Setting.registrations_open?

    Setting.login_link_required = false
    assert_not Setting.login_link_required?
    assert_equal 1, Setting.where(key: "login_link_required").count
  end
end
