require "test_helper"

class RespondentTest < ActiveSupport::TestCase
  test "email must be unique within a campaign" do
    respondent = campaigns(:running_campaign).respondents.build(name: "Doublon", email: "rose@example.com")
    assert_not respondent.valid?
  end

  test "token is generated on creation and is long" do
    respondent = campaigns(:running_campaign).respondents.create!(name: "Nouveau", email: "nouveau@example.com")
    assert_operator respondent.token.length, :>=, 24
  end

  test "a respondent who is also a subject is not asked about themself" do
    emails = respondents(:dana_as_respondent).subjects_to_rate.pluck(:email)
    assert_equal [ "eli@example.com" ], emails
    assert_includes respondents(:rose).subjects_to_rate.pluck(:email), "dana@example.com"
  end
end
