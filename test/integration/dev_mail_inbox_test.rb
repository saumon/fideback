require "test_helper"

class DevMailInboxTest < ActionDispatch::IntegrationTest
  test "the development mail inbox link is absent outside development" do
    get root_path
    assert_response :success
    assert_no_match "letter_opener", response.body

    get respondent_form_path(token: respondents(:rose).token)
    assert_response :success
    assert_no_match "letter_opener", response.body
  end
end
