require "test_helper"

class LoginLinkSignInTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup { Setting.login_link_required = true }

  def sign_in_with_password(manager = managers(:bob), password: "password123")
    post manager_session_path, params: { manager: { email: manager.email, password: password } }
  end

  test "a correct password sends a link and opens no session" do
    assert_enqueued_emails 1 do
      sign_in_with_password
    end
    assert_redirected_to manager_login_link_wait_path

    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "the waiting screen names the address and the rules of the link" do
    sign_in_with_password
    follow_redirect!

    assert_response :success
    assert_select "h2", "Consultez votre boîte mail"
    assert_select ".wait-card strong", "bob@example.com"
    assert_select ".facts li", "Valable 10 minutes"
    assert_select ".facts li", "Un seul usage"
    assert_select "button[disabled]", /Renvoyer le lien dans \d+ s/
    assert_select "button", "Changer d'adresse"
  end

  test "following the link opens the session and lands on the campaigns" do
    sign_in_with_password
    link = LoginLink.last

    get manager_login_link_path(token: link.token)

    assert_redirected_to campaigns_path
    assert_equal "Connecté(e).", flash[:notice]
    follow_redirect!
    assert_response :success
  end

  test "the link works from another browser than the one that typed the password" do
    sign_in_with_password
    link = LoginLink.last

    open_session do |phone|
      phone.get manager_login_link_path(token: link.token)
      phone.assert_redirected_to campaigns_path
      phone.get campaigns_path
      phone.assert_response :success
    end
  end

  test "a link opens once only" do
    sign_in_with_password
    link = LoginLink.last

    get manager_login_link_path(token: link.token)
    delete destroy_manager_session_path
    get manager_login_link_path(token: link.token)

    assert_response :not_found
    assert_select "#login-link-outcome", /n'est plus valable/
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "an expired link is refused" do
    sign_in_with_password
    link = LoginLink.last

    travel 10.minutes + 1.second do
      get manager_login_link_path(token: link.token)
    end

    assert_response :not_found
    assert_select "#login-link-outcome"
    assert_select ".auth-links a[href=?]", new_manager_session_path, "Se reconnecter"
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "an unknown link is refused the same way" do
    get manager_login_link_path(token: "nope")

    assert_response :not_found
    assert_select "#login-link-outcome"
  end

  test "a replaced link is refused" do
    sign_in_with_password
    first = LoginLink.last

    travel 61.seconds do
      post manager_login_link_wait_path
      get manager_login_link_path(token: first.token)
    end

    assert_response :not_found
  end

  test "resending after a minute sends a new link and says so" do
    sign_in_with_password

    travel 61.seconds do
      assert_enqueued_emails 1 do
        post manager_login_link_wait_path
      end
    end

    assert_redirected_to manager_login_link_wait_path
    assert_equal "Un nouveau lien a été envoyé. Le précédent ne fonctionne plus.", flash[:notice]
  end

  test "resending too soon sends nothing and asks to wait" do
    sign_in_with_password

    assert_no_enqueued_emails do
      post manager_login_link_wait_path
    end

    assert_redirected_to manager_login_link_wait_path
    assert_equal "Un lien vient d'être envoyé. Patientez une minute avant d'en demander un autre.", flash[:warning]
  end

  test "typing the password again within a minute sends no second email but shows the waiting screen" do
    sign_in_with_password

    assert_no_enqueued_emails do
      sign_in_with_password
    end
    assert_redirected_to manager_login_link_wait_path
  end

  test "changing the address forgets the pending sign-in" do
    sign_in_with_password
    delete manager_login_link_wait_path
    assert_redirected_to new_manager_session_path

    get manager_login_link_wait_path
    assert_redirected_to new_manager_session_path
    post manager_login_link_wait_path
    assert_redirected_to new_manager_session_path
  end

  test "the waiting screen needs a validated password" do
    get manager_login_link_wait_path
    assert_redirected_to new_manager_session_path
  end

  test "a wrong password sends nothing and keeps the usual message" do
    assert_no_enqueued_emails do
      sign_in_with_password(password: "wrong")
    end

    assert_response :unprocessable_content
    assert_select ".toast, .flash", /invalide|incorrect/i
    get manager_login_link_wait_path
    assert_redirected_to new_manager_session_path
  end

  test "an unknown address looks like a wrong password and sends nothing" do
    assert_no_enqueued_emails do
      post manager_session_path, params: { manager: { email: "nobody@example.com", password: "password123" } }
    end

    assert_response :unprocessable_content
  end

  test "an account that is not activated gets the usual message and no link" do
    managers(:bob).update_columns(confirmed_at: nil)

    assert_no_enqueued_emails do
      sign_in_with_password
    end

    assert_redirected_to new_manager_session_path
    assert_match(/confirmer|activer/i, flash[:alert].to_s)
    assert_equal 0, LoginLink.count
  end

  test "a manager who is already signed in is sent away from the link without using it" do
    sign_in managers(:alice)
    link = LoginLink.issue_for(managers(:bob))

    get manager_login_link_path(token: link.token)

    assert_redirected_to campaigns_path
    assert link.reload.usable?
  end

  test "with the option off, the password alone signs in" do
    Setting.login_link_required = false

    assert_no_enqueued_emails do
      sign_in_with_password
    end

    assert_redirected_to campaigns_path
    get campaigns_path
    assert_response :success
  end

  test "the sign-in form hides the remember-me box while the option is on" do
    get new_manager_session_path
    assert_select "input[name='manager[remember_me]']", false

    Setting.login_link_required = false
    get new_manager_session_path
    assert_select "input[name='manager[remember_me]']"
  end

  test "a remember-me cookie issued before the option no longer signs in" do
    Setting.login_link_required = false
    post manager_session_path, params: { manager: { email: "bob@example.com", password: "password123", remember_me: "1" } }
    assert cookies["remember_manager_token"].present?

    Setting.login_link_required = true
    cookies.delete(Rails.application.config.session_options[:key])
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "a new password does not sign in while the option is on" do
    raw = managers(:bob).send_reset_password_instructions

    put manager_password_path, params: { manager: { reset_password_token: raw, password: "newpassword1", password_confirmation: "newpassword1" } }

    assert_redirected_to new_manager_session_path
    assert managers(:bob).reload.valid_password?("newpassword1")
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "a new password still signs in with the option off" do
    Setting.login_link_required = false
    raw = managers(:bob).send_reset_password_instructions

    put manager_password_path, params: { manager: { reset_password_token: raw, password: "newpassword1", password_confirmation: "newpassword1" } }

    assert_redirected_to campaigns_path
  end

  test "sessions opened before the option was turned on stay valid" do
    Setting.login_link_required = false
    sign_in managers(:bob)
    get campaigns_path
    assert_response :success

    Setting.login_link_required = true
    get campaigns_path
    assert_response :success
  end
end
