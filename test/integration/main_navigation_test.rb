require "test_helper"

class MainNavigationTest < ActionDispatch::IntegrationTest
  def current_entries
    css_select("header nav a[aria-current]").map(&:text)
  end

  test "the campaigns list highlights Mes campagnes only" do
    sign_in managers(:alice)

    get campaigns_path

    assert_equal [ "Mes campagnes" ], current_entries
    assert_select "header nav a[aria-current=page]", count: 1
  end

  test "every campaign screen highlights Mes campagnes" do
    sign_in managers(:alice)
    campaign = campaigns(:draft_campaign)
    summary = campaign_summary_path(campaigns(:running_campaign), subject_id: subjects(:dana).id)

    [ new_campaign_path, campaign_path(campaign), edit_campaign_path(campaign), summary ].each do |path|
      get path
      assert_equal [ "Mes campagnes" ], current_entries, path
    end
  end

  test "the team screen highlights Mon équipe" do
    sign_in managers(:alice)

    get team_path

    assert_equal [ "Mon équipe" ], current_entries
  end

  test "the administration screens highlight Administration" do
    sign_in managers(:alice)

    [ admin_root_path, admin_users_path ].each do |path|
      get path
      assert_equal [ "Administration" ], current_entries, path
    end
  end

  test "the account screen highlights the manager's name, also after a refused update" do
    sign_in managers(:alice)

    get edit_manager_registration_path
    assert_equal [ managers(:alice).name ], current_entries

    patch manager_registration_path, params: { manager: { name: "", current_password: "password123" } }
    assert_response :unprocessable_content
    assert_equal [ managers(:alice).name ], current_entries
  end

  test "the sign-in page highlights Se connecter" do
    get new_manager_session_path

    assert_equal [ "Se connecter" ], current_entries
  end

  test "the sign-up page highlights nothing, Créer un compte being a button" do
    get new_manager_registration_path

    assert_empty current_entries
  end

  test "a 404 highlights nothing" do
    sign_in managers(:alice)

    get "/nulle-part"

    assert_response :not_found
    assert_empty current_entries
  end

  test "a respondent's page highlights nothing" do
    get respondent_form_path(token: respondents(:rose).token)

    assert_empty current_entries
  end
end
