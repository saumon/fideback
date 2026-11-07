require "test_helper"

class AdminInvitationsTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  def invite!(email: "pat@example.com", name: "Pat Durand")
    Invitation.invite(name: name, email: email, by: managers(:alice))
  end

  test "the users screen offers the invite button, and an empty tracking block" do
    sign_in managers(:alice)

    get admin_users_path

    assert_select "a.btn[href=?]", new_admin_invitation_path, text: "Inviter un manager"
    assert_select "#invitations-title", "Invitations en attente"
    assert_select ".empty", text: /Aucune invitation en attente/
  end

  test "an admin sees the invitation form" do
    sign_in managers(:alice)

    get new_admin_invitation_path

    assert_response :success
    assert_select "h2", "Inviter un manager"
    assert_select "form[action=?]", admin_invitations_path
    assert_select "input[name='invitation[name]']"
    assert_select "input[name='invitation[email]']"
  end

  test "a manager who is not an admin gets a 404 on every invitation action" do
    sign_in managers(:bob)
    invitation = invite!

    get new_admin_invitation_path
    assert_response :not_found
    post admin_invitations_path, params: { invitation: { name: "X", email: "x@example.com" } }
    assert_response :not_found
    post resend_admin_invitation_path(invitation)
    assert_response :not_found
    delete admin_invitation_path(invitation)
    assert_response :not_found

    assert_equal 1, Invitation.count
    assert_nil Invitation.find_by(email: "x@example.com")
  end

  test "a visitor is sent to the sign-in page" do
    get new_admin_invitation_path
    assert_redirected_to new_manager_session_path

    post admin_invitations_path, params: { invitation: { name: "X", email: "x@example.com" } }
    assert_redirected_to new_manager_session_path
    assert_equal 0, Invitation.count
  end

  test "inviting creates the invitation, queues the email and confirms" do
    sign_in managers(:alice)

    assert_enqueued_emails 1 do
      post admin_invitations_path, params: { invitation: { name: "Pat Durand", email: "pat@example.com" } }
    end

    assert_redirected_to admin_users_path
    assert_equal "Invitation envoyée à pat@example.com.", flash[:notice]
    assert_equal 1, Invitation.unaccepted.count
  end

  test "inviting works while registrations are closed" do
    Setting.registrations_open = false
    sign_in managers(:alice)

    assert_difference "Invitation.count", 1 do
      post admin_invitations_path, params: { invitation: { name: "Pat Durand", email: "pat@example.com" } }
    end
    assert_redirected_to admin_users_path
  end

  test "invalid input shows the errors and creates nothing" do
    sign_in managers(:alice)

    assert_no_enqueued_emails do
      post admin_invitations_path, params: { invitation: { name: "", email: "nope" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation li", minimum: 2
    assert_equal 0, Invitation.count
  end

  test "an address that already has an account is refused" do
    sign_in managers(:alice)

    assert_no_enqueued_emails do
      post admin_invitations_path, params: { invitation: { name: "Bob", email: "BOB@example.com" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation li"
    assert_equal 0, Invitation.count
  end

  test "inviting an invited address replaces the invitation" do
    old = invite!
    sign_in managers(:alice)

    assert_enqueued_emails 1 do
      post admin_invitations_path, params: { invitation: { name: "Patricia", email: "pat@example.com" } }
    end

    assert_equal 1, Invitation.count
    assert_equal "Patricia", old.reload.name
  end

  test "the tracking block lists pending and expired invitations, newest first, with their actions" do
    invite!(email: "old@example.com", name: "Sam Lopez").update_columns(created_at: 3.days.ago, expires_at: 1.day.ago)
    recent = invite!
    sign_in managers(:alice)

    get admin_users_path

    ids = css_select("#invitations-title ~ .table-scroll tbody tr").map { |row| row["id"] }
    assert_equal [ dom_id(recent), dom_id(Invitation.find_by!(email: "old@example.com")) ], ids
    assert_select "##{dom_id(recent)} .status-pending", "En attente"
    assert_select "##{dom_id(Invitation.find_by!(email: 'old@example.com'))} .status-expired", "Expirée"
    assert_select "##{dom_id(recent)} form[action=?] button", resend_admin_invitation_path(recent), text: "Renvoyer"
    assert_select "##{dom_id(recent)} form[action=?] button", admin_invitation_path(recent), text: "Annuler"
  end

  test "an accepted invitation leaves the block and the person joins the managers" do
    invitation = invite!
    invitation.accept(name: "Pat Durand", password: "password123", password_confirmation: "password123")
    sign_in managers(:alice)

    get admin_users_path

    assert_select "#invitations-title ~ .table-scroll", false
    assert_select ".empty", text: /Aucune invitation en attente/
    assert_select "td", text: "pat@example.com"
  end

  test "resending an expired invitation renews it with a new link and a new email" do
    invitation = invite!
    invitation.update_columns(expires_at: 1.day.ago)
    old_token = invitation.token
    sign_in managers(:alice)

    assert_enqueued_emails 1 do
      post resend_admin_invitation_path(invitation)
    end

    assert_redirected_to admin_users_path
    assert_equal "Invitation renvoyée à pat@example.com.", flash[:notice]
    assert invitation.reload.pending?
    assert_not_equal old_token, invitation.token
  end

  test "resending to an address that has since registered is refused" do
    invitation = invite!
    Manager.create!(name: "Pat", email: "pat@example.com", password: "password123")
    sign_in managers(:alice)

    assert_no_enqueued_emails { post resend_admin_invitation_path(invitation) }

    assert_redirected_to admin_users_path
    assert_match(/ne peut plus être renvoyée/, flash[:alert])
  end

  test "cancelling removes the invitation and its link stops working" do
    invitation = invite!
    token = invitation.token
    sign_in managers(:alice)

    delete admin_invitation_path(invitation)

    assert_redirected_to admin_users_path
    assert_equal "Invitation à pat@example.com annulée.", flash[:notice]
    assert_equal 0, Invitation.count

    sign_out :manager
    get invitation_acceptance_path(token: token)
    assert_response :not_found
  end

  test "the only action on existing accounts is deletion" do
    sign_in managers(:alice)

    get admin_users_path

    assert_select "table:first-of-type form", Manager.count - 1
    assert_select "table:first-of-type form" do |forms|
      forms.each { |form| assert_equal "delete", form.at_css("input[name=_method]")["value"] }
    end
  end
end
