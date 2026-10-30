require "test_helper"

class AdminAreaTest < ActionDispatch::IntegrationTest
  test "an admin sees the administration screen, with no action on it" do
    sign_in managers(:alice)

    get admin_root_path

    assert_response :success
    assert_select "h1", "Administration"
    assert_select "main form, main button, main input", false
  end

  test "a manager who is not an admin gets a 404" do
    sign_in managers(:bob)

    get admin_root_path

    assert_response :not_found
  end

  test "a visitor is sent to the sign-in page" do
    get admin_root_path

    assert_redirected_to new_manager_session_path
  end

  test "the menu links to the administration for an admin only" do
    sign_in managers(:alice)
    get campaigns_path
    assert_select "nav a[href=?]", admin_root_path, text: "Administration"

    sign_out :manager
    sign_in managers(:bob)
    get campaigns_path
    assert_select "nav a", text: "Administration", count: 0

    sign_out :manager
    get new_manager_session_path
    assert_select "nav a", text: "Administration", count: 0
  end
end
