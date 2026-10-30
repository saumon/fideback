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

  test "the screen offers no action on accounts" do
    sign_in managers(:alice)

    get admin_users_path

    assert_select "main form, main button, main input", false
  end
end
