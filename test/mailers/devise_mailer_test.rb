require "test_helper"

class DeviseMailerTest < ActionMailer::TestCase
  setup { @manager = managers(:alice) }

  test "account emails wear the same frame as the respondent invitation" do
    mails = [
      Devise::Mailer.confirmation_instructions(@manager, "token"),
      Devise::Mailer.reset_password_instructions(@manager, "token"),
      RespondentMailer.invitation(respondents(:rose))
    ]

    mails.each do |mail|
      html = mail.html_part.body.to_s
      assert_includes html, ">Fideback</p>", mail.subject
      assert_includes html, "linear-gradient", mail.subject
    end
  end

  test "activation email greets by name in text and html, with the full link in text" do
    mail = Devise::Mailer.confirmation_instructions(@manager, "token")

    assert_greeting_and_link mail, "/managers/confirmation?confirmation_token=token"
  end

  test "reset password email greets by name in text and html, with the full link in text" do
    mail = Devise::Mailer.reset_password_instructions(@manager, "token")

    assert_greeting_and_link mail, "/managers/password/edit?reset_password_token=token"
    assert_not_includes mail.html_part.body.to_s, "Bonjour alice@example.com"
  end

  private
    def assert_greeting_and_link(mail, path)
      [ mail.text_part, mail.html_part ].each do |part|
        assert_includes part.body.to_s, "Bonjour Alice Manager,"
      end
      assert_includes mail.text_part.body.to_s, "http://example.com#{path}"
    end
end
