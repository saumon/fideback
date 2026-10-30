require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  setup do
    @invitation = Invitation.create!(name: "Pat Durand", email: "pat@example.com", invited_by: managers(:alice), expires_at: Invitation::VALIDITY.from_now)
  end

  test "the invitation greets by name, names the inviter and carries the personal link in both versions" do
    mail = InvitationMailer.invitation(@invitation)

    assert_equal [ "pat@example.com" ], mail.to
    assert_equal "Alice Manager vous invite à rejoindre Fideback", mail.subject
    [ mail.text_part, mail.html_part ].each do |part|
      body = part.body.to_s
      assert_includes body, "Bonjour Pat Durand,"
      assert_includes body, "Alice Manager"
      assert_includes body, "/invitations/#{@invitation.token}"
      assert_includes body, I18n.l(@invitation.expires_at.to_date, format: :long)
      assert_includes body, "Ce lien est personnel"
    end
    assert_includes mail.html_part.body.to_s, "Accepter l&#39;invitation"
  end

  test "the invitation wears the common frame and shares the application's sender" do
    mail = InvitationMailer.invitation(@invitation)

    assert_includes mail.html_part.body.to_s, ">Fideback</p>"
    assert_includes mail.html_part.body.to_s, "linear-gradient"
    assert_equal Fideback::MailerSettings.mailer_sender, mail[:from].value
  end

  test "an invitation whose inviter was removed still names an administrator" do
    managers(:alice).update_columns(name: "Alice Manager")
    @invitation.update_columns(invited_by_id: nil)

    assert_equal "Un administrateur vous invite à rejoindre Fideback", InvitationMailer.invitation(@invitation.reload).subject
  end
end
