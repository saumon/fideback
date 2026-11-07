require "test_helper"

class AdminUsersTest < ActionDispatch::IntegrationTest
  test "an admin sees the users screen" do
    sign_in managers(:alice)

    get admin_users_path

    assert_response :success
    assert_select "h1", "Utilisateurs"
    assert_select "main a[href=?]", admin_root_path
  end

  test "a manager who is not an admin gets a 404" do
    sign_in managers(:bob)

    get admin_users_path

    assert_response :not_found
  end

  test "a visitor is sent to the sign-in page" do
    get admin_users_path

    assert_redirected_to new_manager_session_path
  end

  test "each manager is listed with name, email, role and registration date" do
    sign_in managers(:alice)

    get admin_users_path

    assert_select "tbody tr", Manager.count
    assert_select "##{dom_id(managers(:alice))}" do
      assert_select "td", text: /Alice Manager/
      assert_select "td", text: "alice@example.com"
      assert_select ".status-admin", "Admin"
      assert_select "td", text: I18n.l(managers(:alice).created_at, format: :short)
    end
    assert_select "##{dom_id(managers(:bob))} .status-manager", "Manager"
  end

  test "only unconfirmed accounts carry the unconfirmed badge" do
    managers(:bob).update_columns(confirmed_at: nil)
    sign_in managers(:alice)

    get admin_users_path

    assert_select "##{dom_id(managers(:bob))} .status-unconfirmed", "Non confirmé"
    assert_select "##{dom_id(managers(:alice))} .status-unconfirmed", false
    assert_select ".status-unconfirmed", 1
  end

  test "the newest registration comes first" do
    managers(:alice).update_columns(created_at: 3.days.ago)
    managers(:bob).update_columns(created_at: 2.days.ago)
    carol = Manager.create!(name: "Carol", email: "carol@example.com", password: "password123", confirmed_at: Time.current)
    sign_in managers(:alice)

    get admin_users_path

    ids = css_select("tbody tr").map { |row| row["id"] }
    assert_equal [ carol, managers(:bob), managers(:alice) ].map { |m| dom_id(m) }, ids
  end

  test "the screen offers no role change or edit, only deletion of the other managers, and actions on invitations" do
    sign_in managers(:alice)

    get admin_users_path

    assert_select "table:first-of-type input:not([name=authenticity_token]):not([name=_method])", false
    assert_select "table:first-of-type form", Manager.count - 1
    assert_select "table:first-of-type form[action=?]", admin_user_path(managers(:bob))
    assert_select "main a.btn", text: "Inviter un manager"
  end

  test "the delete button is absent from the signed-in admin's own row" do
    sign_in managers(:alice)

    get admin_users_path

    assert_select "##{dom_id(managers(:alice))} button", false
    assert_select "##{dom_id(managers(:bob))} button", text: "Supprimer"
  end

  test "the confirmation counts the campaigns that will be lost" do
    Campaign.create!(manager: managers(:bob), name: "Autre", deadline_on: 10.days.from_now.to_date)
    sign_in managers(:alice)

    get admin_users_path

    assert_select "##{dom_id(managers(:bob))} form[data-turbo-confirm=?][data-turbo-confirm-tone=danger]", "Supprimer Bob Manager ?" do |forms|
      assert_includes forms.first["data-turbo-confirm-detail"], "Ses 2 campagnes et toutes les réponses recueillies seront effacées."
    end
  end

  test "an admin deletes a manager" do
    sign_in managers(:alice)

    assert_difference "Manager.count", -1 do
      delete admin_user_path(managers(:bob))
    end

    assert_redirected_to admin_users_path
    assert_response :see_other
    assert_equal "Bob Manager a été supprimé.", flash[:notice]
    assert_not Manager.exists?(managers(:bob).id)
  end

  test "an unconfirmed manager is deleted like any other" do
    managers(:bob).update_columns(confirmed_at: nil)
    sign_in managers(:alice)

    assert_difference "Manager.count", -1 do
      delete admin_user_path(managers(:bob))
    end
  end

  test "an admin cannot delete their own account" do
    sign_in managers(:alice)

    assert_no_difference [ "Manager.count", "Campaign.count" ] do
      delete admin_user_path(managers(:alice))
    end

    assert_redirected_to admin_users_path
    assert_equal "Vous ne pouvez pas supprimer votre propre compte.", flash[:alert]
    get admin_users_path
    assert_response :success
  end

  test "a manager who is not an admin cannot delete anyone" do
    sign_in managers(:bob)

    assert_no_difference "Manager.count" do
      delete admin_user_path(managers(:alice))
    end

    assert_response :not_found
  end

  test "a visitor cannot delete anyone" do
    assert_no_difference "Manager.count" do
      delete admin_user_path(managers(:bob))
    end

    assert_redirected_to new_manager_session_path
  end

  test "deleting a manager who no longer exists is a 404" do
    sign_in managers(:alice)
    id = managers(:bob).id
    managers(:bob).destroy!

    assert_no_difference "Manager.count" do
      delete admin_user_path(id)
    end

    assert_response :not_found
  end

  test "deletion removes the campaigns, answers, contacts and login links, and keeps the invitations sent" do
    bob = managers(:bob)
    campaign = campaigns(:running_campaign)
    campaign.update_columns(manager_id: bob.id)
    answer_fully(respondents(:rose))
    contacts(:dana).update_columns(manager_id: bob.id)
    bob.login_links.create!(expires_at: 10.minutes.from_now)
    invitation = Invitation.invite(name: "Pat", email: "pat@example.com", by: bob)
    respondent_ids = campaign.respondents.ids
    assert campaign.running? && Answer.where(respondent_id: respondent_ids).any?
    sign_in managers(:alice)

    assert_no_enqueued_emails do
      delete admin_user_path(bob)
    end

    assert_not Campaign.exists?(campaign.id)
    assert_empty Campaign.where(manager_id: bob.id)
    assert_empty Respondent.where(id: respondent_ids)
    assert_empty Answer.where(respondent_id: respondent_ids)
    assert_empty Contact.where(manager_id: bob.id)
    assert_empty LoginLink.where(manager_id: bob.id)
    assert_nil invitation.reload.invited_by
    get admin_users_path
    assert_select "##{dom_id(invitation)}"
  end

  test "a deleted manager's email can be invited and registered again" do
    sign_in managers(:alice)
    delete admin_user_path(managers(:bob))

    assert Invitation.invite(name: "Bob", email: "bob@example.com", by: managers(:alice)).persisted?
  end

  test "a deleted manager's open session no longer gives access" do
    sign_in managers(:bob)
    get campaigns_path
    assert_response :success

    admin = open_session
    admin.extend(Devise::Test::IntegrationHelpers)
    admin.sign_in managers(:alice)
    admin.delete admin_user_path(managers(:bob))
    assert_equal 303, admin.response.status

    get campaigns_path
    assert_redirected_to new_manager_session_path
  end
end
