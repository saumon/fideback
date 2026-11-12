require "test_helper"

class MobileNavigationTest < ActionDispatch::IntegrationTest
  test "the menu button announces the drawer it controls, closed by default" do
    sign_in managers(:alice)

    get campaigns_path

    assert_select "header .header-end button.nav-toggle[hidden][aria-controls=site-nav][aria-expanded=false][aria-label='Ouvrir le menu']"
    assert_select "header nav#site-nav"
  end

  test "an admin's drawer lists the entries, then a separate block with the name and the sign-out" do
    sign_in managers(:alice)

    get campaigns_path

    assert_select "nav#site-nav > a", %w[ Mes\ campagnes Mon\ équipe Mes\ modèles Administration ].size
    assert_select "nav#site-nav .nav-account" do
      assert_select ".nav-who", "Connecté"
      assert_select "a[href=?]", edit_manager_registration_path, text: managers(:alice).name
      assert_select "button", "Se déconnecter"
    end
    assert_select ".header-end > a.btn", false
  end

  test "a manager who is not an admin has no Administration entry in the drawer" do
    sign_in managers(:bob)

    get campaigns_path

    assert_select "nav#site-nav a", text: "Administration", count: 0
    assert_select "nav#site-nav .nav-account"
  end

  test "a visitor's drawer holds Se connecter, and Créer un compte stays in the header outside the nav" do
    get new_manager_session_path

    assert_select "nav#site-nav a", text: "Se connecter"
    assert_select "nav#site-nav a", text: "Créer un compte", count: 0
    assert_select "nav#site-nav .nav-account", false
    assert_select ".header-end > a.btn[href=?]", new_manager_registration_path, text: "Créer un compte"
  end

  test "a respondent's page has no navigation to collapse" do
    get respondent_form_path(token: respondents(:rose).token)

    assert_select "nav#site-nav", false
    assert_select "button.nav-toggle", false
  end
end
