require "test_helper"

class RespondentMailerTest < ActionMailer::TestCase
  test "invitation contains the personal link, manager name and deadline" do
    respondent = respondents(:rose)
    mail = RespondentMailer.invitation(respondent)

    assert_equal [ "rose@example.com" ], mail.to
    assert_match "Alice Manager", mail.subject
    [ mail.text_part, mail.html_part ].each do |part|
      body = part.body.to_s
      assert_includes body, "/repondre/#{respondent.token}"
      assert_includes body, "Alice Manager"
      assert_includes body, I18n.l(respondent.campaign.deadline_on, format: :long)
      assert_includes body, "nominativement"
    end
  end
end
