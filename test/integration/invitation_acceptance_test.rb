require "test_helper"

class InvitationAcceptanceTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup { @invitation = Invitation.invite(name: "Pat Durand", email: "pat@example.com", by: managers(:alice)) }

  def accept(token: @invitation.token, name: "Pat Durand", password: "password123", confirmation: password)
    patch invitation_acceptance_path(token: token), params: { manager: { name: name, password: password, password_confirmation: confirmation } }
  end

  test "the page shows the invited name, a locked email and the password fields" do
    get invitation_acceptance_path(token: @invitation.token)

    assert_response :success
    assert_select "h2", "Bienvenue"
    assert_select "input[name='manager[name]'][value='Pat Durand']"
    assert_select "input[name='manager[email]'][value='pat@example.com'][readonly]"
    assert_select "input[name='manager[password]']"
    assert_select "input[name='manager[password_confirmation]']"
  end

  test "accepting creates an activated manager, sends no email, does not sign in and goes to the sign-in page" do
    assert_difference "Manager.count", 1 do
      assert_no_emails { accept }
    end

    assert_redirected_to new_manager_session_path
    assert_equal "Votre compte est créé. Connectez-vous pour commencer.", flash[:notice]
    manager = Manager.find_by!(email: "pat@example.com")
    assert manager.confirmed?
    assert manager.manager?

    get campaigns_path
    assert_redirected_to new_manager_session_path

    post manager_session_path, params: { manager: { email: "pat@example.com", password: "password123" } }
    assert_redirected_to campaigns_path
  end

  test "accepting works while registrations are closed" do
    Setting.registrations_open = false

    get invitation_acceptance_path(token: @invitation.token)
    assert_response :success

    assert_difference("Manager.count", 1) { accept }
  end

  test "the invitee can correct the name" do
    accept(name: "Patricia Durand")

    assert_equal "Patricia Durand", Manager.find_by!(email: "pat@example.com").name
  end

  test "an invalid password shows the errors, keeps the typed name and creates nothing" do
    assert_no_difference "Manager.count" do
      accept(name: "Pat D.", password: "abc")
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation li"
    assert_select "input[name='manager[name]'][value='Pat D.']"
    assert @invitation.reload.pending?
  end

  test "a mismatching confirmation is refused" do
    assert_no_difference("Manager.count") { accept(confirmation: "different123") }

    assert_response :unprocessable_entity
  end

  test "the posted email can't be changed: the invited address is always used" do
    patch invitation_acceptance_path(token: @invitation.token), params: { manager: { name: "Pat", email: "someone@else.com", password: "password123", password_confirmation: "password123" } }

    assert_nil Manager.find_by(email: "someone@else.com")
    assert Manager.find_by(email: "pat@example.com")
  end

  test "a used link leads to the explanatory page" do
    accept
    get invitation_acceptance_path(token: @invitation.token)

    assert_response :not_found
    assert_select "h2", "Invitation invalide"
    assert_select "#invitation-outcome", text: /Demandez à l'administrateur/
  end

  test "an expired link leads to the explanatory page and creates nothing" do
    travel 8.days do
      get invitation_acceptance_path(token: @invitation.token)
      assert_response :not_found
      assert_select "h2", "Invitation invalide"

      assert_no_difference("Manager.count") { accept }
      assert_response :not_found
    end
  end

  test "an unknown link and a replaced link lead to the explanatory page" do
    old_token = @invitation.token
    Invitation.invite(name: "Pat Durand", email: "pat@example.com", by: managers(:alice))

    get invitation_acceptance_path(token: "nope")
    assert_response :not_found

    get invitation_acceptance_path(token: old_token)
    assert_response :not_found
  end

  test "a link whose address registered meanwhile leads to the explanatory page, even on submission" do
    Manager.create!(name: "Pat", email: "pat@example.com", password: "password123")

    get invitation_acceptance_path(token: @invitation.token)
    assert_response :not_found

    assert_no_difference("Manager.count") { accept }
    assert_response :not_found
  end

  test "a signed-in manager is sent back to the campaigns with a message" do
    sign_in managers(:alice)

    get invitation_acceptance_path(token: @invitation.token)

    assert_redirected_to campaigns_path
    assert_equal I18n.t("devise.failure.already_authenticated"), flash[:alert]
    assert_no_difference("Manager.count") { accept }
  end

  test "the sign-up page stays closed for everyone else while registrations are closed" do
    Setting.registrations_open = false

    get new_manager_registration_path

    assert_redirected_to root_path
  end
end
