require "test_helper"

class ManagerAuthTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "sign up with valid data signs in and redirects to campaigns" do
    assert_difference "Manager.count", 1 do
      post manager_registration_path, params: { manager: { name: "Carol", email: "carol@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to campaigns_path
  end

  test "sign up with taken email fails" do
    assert_no_difference "Manager.count" do
      post manager_registration_path, params: { manager: { name: "Dup", email: managers(:alice).email, password: "password123", password_confirmation: "password123" } }
    end
    assert_response :unprocessable_entity
  end

  test "sign in with valid credentials redirects to campaigns" do
    post manager_session_path, params: { manager: { email: managers(:alice).email, password: "password123" } }
    assert_redirected_to campaigns_path
  end

  test "sign in with invalid credentials stays signed out" do
    post manager_session_path, params: { manager: { email: managers(:alice).email, password: "wrong" } }
    assert_response :unprocessable_entity
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "sign out ends the session" do
    sign_in managers(:alice)
    delete destroy_manager_session_path
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "password reset sends an email for a known address" do
    assert_emails 1 do
      post manager_password_path, params: { manager: { email: managers(:alice).email } }
    end
  end

  test "password reset for unknown address looks identical and sends nothing" do
    post manager_password_path, params: { manager: { email: managers(:alice).email } }
    known = flash[:notice]
    assert_no_emails do
      post manager_password_path, params: { manager: { email: "nobody@example.com" } }
    end
    assert_equal known, flash[:notice]
  end

  test "anonymous visitor is redirected to sign in" do
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "sign in and sign up pages render" do
    get new_manager_session_path
    assert_response :success
    get new_manager_registration_path
    assert_response :success
    assert_select "input[name='manager[name]']"
  end
end
