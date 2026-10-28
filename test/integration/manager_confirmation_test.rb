require "test_helper"

class ManagerConfirmationTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  # Inscrit un manager et renvoie le jeton du lien reçu par e-mail.
  def sign_up(email: "carol@example.com")
    post manager_registration_path, params: { manager: { name: "Carol", email: email, password: "password123", password_confirmation: "password123" } }
    token_from(ActionMailer::Base.deliveries.last)
  end

  def token_from(mail)
    mail.html_part.body.to_s[/confirmation_token=([^"&\s]+)/, 1]
  end

  def request_new_link(email)
    post manager_confirmation_path, params: { manager: { email: email } }
  end

  test "the activation email carries a link, in HTML and text, valid for 24 hours" do
    token = sign_up
    mail = ActionMailer::Base.deliveries.last

    assert_equal I18n.t("devise.mailer.confirmation_instructions.subject"), mail.subject
    [ mail.html_part, mail.text_part ].each do |part|
      assert_includes part.body.to_s, "/managers/confirmation?confirmation_token=#{token}"
      assert_includes part.body.to_s, "24 heures"
    end
  end

  test "a valid link activates the account and sends to sign in without signing in" do
    token = sign_up

    get manager_confirmation_path(confirmation_token: token)

    assert_redirected_to new_manager_session_path
    assert_equal I18n.t("devise.confirmations.confirmed"), flash[:notice]
    assert Manager.find_by(email: "carol@example.com").confirmed?
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "an activated manager can sign in" do
    token = sign_up
    get manager_confirmation_path(confirmation_token: token)

    post manager_session_path, params: { manager: { email: "carol@example.com", password: "password123" } }
    assert_redirected_to campaigns_path
  end

  test "a link already used says the account is active and offers to sign in" do
    token = sign_up
    get manager_confirmation_path(confirmation_token: token)

    get manager_confirmation_path(confirmation_token: token)

    assert_response :unprocessable_entity
    assert_select "#confirmation-outcome", text: /déjà activé/
    assert_select "#confirmation-outcome a[href=?]", new_manager_session_path
  end

  test "an expired link leaves the account inactive and says so" do
    token = sign_up

    travel 25.hours do
      get manager_confirmation_path(confirmation_token: token)
    end

    assert_response :unprocessable_entity
    assert_select "#confirmation-outcome", text: /expiré/
    assert_not Manager.find_by(email: "carol@example.com").confirmed?
  end

  test "an unknown link says it is not recognised" do
    get manager_confirmation_path(confirmation_token: "nope")

    assert_response :unprocessable_entity
    assert_select "#confirmation-outcome", text: /pas reconnu/
  end

  test "asking for a new email sends one and the earlier link stops working" do
    old_token = sign_up

    travel 6.minutes do
      assert_emails 1 do
        request_new_link("carol@example.com")
      end
      new_token = token_from(ActionMailer::Base.deliveries.last)
      assert_not_equal old_token, new_token

      get manager_confirmation_path(confirmation_token: old_token)
      assert_response :unprocessable_entity
      assert_select "#confirmation-outcome", text: /pas reconnu/

      get manager_confirmation_path(confirmation_token: new_token)
      assert_redirected_to new_manager_session_path
    end
  end

  test "requests less than five minutes apart send nothing" do
    sign_up

    travel 4.minutes do
      assert_no_emails { request_new_link("carol@example.com") }
    end
  end

  test "unknown and already active addresses send nothing" do
    assert_no_emails do
      request_new_link("nobody@example.com")
      request_new_link(managers(:alice).email)
    end
  end

  test "the answer is identical whatever the address" do
    sign_up
    answers = [ "carol@example.com", "nobody@example.com", managers(:alice).email ].map do |email|
      request_new_link(email)
      [ response.status, response.location, flash[:notice] ]
    end

    travel 6.minutes do
      request_new_link("carol@example.com")
      answers << [ response.status, response.location, flash[:notice] ]
    end

    assert_equal 1, answers.uniq.size
    assert_equal new_manager_session_path, URI(answers.first[1]).path
  end

  test "the new link page renders" do
    get new_manager_confirmation_path
    assert_response :success
    assert_select "input[name='manager[email]']"
  end

  test "an inactive manager with the right password is told to activate" do
    sign_up

    post manager_session_path, params: { manager: { email: "carol@example.com", password: "password123" } }

    assert_redirected_to new_manager_session_path
    follow_redirect!
    assert_includes CGI.unescapeHTML(response.body), I18n.t("devise.failure.unconfirmed")
    get campaigns_path
    assert_redirected_to new_manager_session_path
  end

  test "an inactive manager with a wrong password gets the generic message" do
    sign_up

    post manager_session_path, params: { manager: { email: "carol@example.com", password: "wrong" } }
    inactive_body = CGI.unescapeHTML(response.body)
    post manager_session_path, params: { manager: { email: managers(:alice).email, password: "wrong" } }
    active_body = CGI.unescapeHTML(response.body)

    assert_response :unprocessable_entity
    generic = I18n.t("devise.failure.invalid", authentication_keys: Manager.human_attribute_name(:email))
    assert_includes inactive_body, generic
    assert_includes active_body, generic
    assert_not_includes inactive_body, I18n.t("devise.failure.unconfirmed")
  end

  test "a manager who existed before activation was introduced signs in normally" do
    post manager_session_path, params: { manager: { email: managers(:bob).email, password: "password123" } }
    assert_redirected_to campaigns_path
  end
end
