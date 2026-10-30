require "test_helper"

class RegistrationLockTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  SIGN_UP = { manager: { name: "Carol", email: "carol@example.com", password: "password123", password_confirmation: "password123" } }.freeze

  setup { Setting.registrations_open = false }

  test "opening the sign-up page sends the visitor home with a warning" do
    get new_manager_registration_path

    assert_redirected_to root_path
    assert_equal "Les inscriptions sont fermées pour le moment.", flash[:warning]

    follow_redirect!
    assert_response :success
    assert_select ".toast.flash-warning p", "Les inscriptions sont fermées pour le moment."
  end

  test "submitting the form creates no account and sends no email" do
    assert_no_difference "Manager.count" do
      assert_no_emails do
        post manager_registration_path, params: SIGN_UP
      end
    end

    assert_redirected_to root_path
    assert_equal "Les inscriptions sont fermées pour le moment.", flash[:warning]
  end

  test "the sign-up buttons stay visible while registrations are closed" do
    get root_path
    assert_select "a[href=?]", new_manager_registration_path, text: "Créer un compte", minimum: 2

    get new_manager_session_path
    assert_select "a[href=?]", new_manager_registration_path, text: "Créer un compte", minimum: 1
  end

  test "sign-up works again once registrations are reopened" do
    Setting.registrations_open = true

    get new_manager_registration_path
    assert_response :success

    assert_difference "Manager.count", 1 do
      post manager_registration_path, params: SIGN_UP
    end
  end

  test "with no manager at all, the first account can still sign up and becomes admin" do
    Manager.destroy_all

    get new_manager_registration_path
    assert_response :success

    assert_difference "Manager.count", 1 do
      post manager_registration_path, params: SIGN_UP
    end
    assert Manager.find_by!(email: "carol@example.com").admin?
  end

  test "existing accounts keep their activation, resend and sign-in" do
    pending = Manager.create!(name: "Pat", email: "pat@example.com", password: "password123")
    assert_not pending.confirmed?

    get manager_confirmation_path(confirmation_token: pending.confirmation_token)
    assert_redirected_to new_manager_session_path
    assert pending.reload.confirmed?

    post manager_session_path, params: { manager: { email: "alice@example.com", password: "password123" } }
    assert_redirected_to campaigns_path

    delete destroy_manager_session_path
    post manager_password_path, params: { manager: { email: "alice@example.com" } }
    assert_redirected_to new_manager_session_path
  end

  test "a signed-in manager opening the sign-up page keeps Devise's answer, not the warning" do
    sign_in managers(:alice)

    get new_manager_registration_path

    assert_nil flash[:warning]
  end
end
