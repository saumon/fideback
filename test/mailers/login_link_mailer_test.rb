require "test_helper"

class LoginLinkMailerTest < ActionMailer::TestCase
  setup do
    @link = managers(:bob).login_links.create!(expires_at: LoginLink::VALIDITY.from_now)
  end

  test "the email greets by name and carries the personal link in both versions" do
    mail = LoginLinkMailer.link(@link)

    assert_equal [ "bob@example.com" ], mail.to
    assert_equal "Votre lien de connexion à Fideback", mail.subject
    [ mail.text_part, mail.html_part ].each do |part|
      body = part.body.to_s
      assert_includes body, "Bonjour Bob Manager,"
      assert_includes body, "/managers/sign_in/link/#{@link.token}"
      assert_includes body, "10 minutes"
      assert_includes body, "ne sert qu'une fois"
    end
    assert_includes mail.html_part.body.to_s, "Me connecter"
  end

  test "the email wears the common frame and shares the application's sender" do
    mail = LoginLinkMailer.link(@link)

    assert_includes mail.html_part.body.to_s, ">Fideback</p>"
    assert_equal Fideback::MailerSettings.mailer_sender, mail[:from].value
  end
end
