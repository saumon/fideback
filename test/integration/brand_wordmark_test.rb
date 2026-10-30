require "test_helper"

class BrandWordmarkTest < ActionDispatch::IntegrationTest
  test "manager and respondent headers keep the wordmark in one piece" do
    get root_path
    assert_wordmark

    get respondent_form_path(token: respondents(:rose).token)
    assert_wordmark
  end

  private
    def assert_wordmark
      assert_select ".site-header .brand .brand-name", text: "Fideback", count: 1
      assert_select ".site-header .brand .brand-name *", count: 0
    end
end
