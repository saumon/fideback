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

  test "invitation does not present the campaign as preparing individual reviews" do
    mail = RespondentMailer.invitation(respondents(:rose))
    [ mail.text_part, mail.html_part ].each do |part|
      assert_no_match(/entretien/i, part.body.to_s)
      assert_includes part.body.to_s, "vous invite à donner votre feedback dans la campagne « Campagne en cours »"
    end
  end

  test "invitation shows the campaign purpose when set, in both versions" do
    respondent = respondents(:rose)
    respondent.campaign.update!(purpose: "Faire le point après <b>le projet</b>.\nMerci !")
    mail = RespondentMailer.invitation(respondent)

    assert_includes mail.text_part.body.to_s, "Pourquoi cette campagne ?\nFaire le point après <b>le projet</b>.\nMerci !"
    html = mail.html_part.body.to_s
    assert_includes html, "Pourquoi cette campagne ?"
    assert_includes html, "Faire le point après &lt;b&gt;le projet&lt;/b&gt;."
    assert_not_includes html, "<b>le projet</b>"
  end

  test "invitation has no purpose block without a purpose, even blank" do
    [ nil, "  " ].each do |purpose|
      respondents(:rose).campaign.update!(purpose: purpose)
      mail = RespondentMailer.invitation(respondents(:rose))
      [ mail.text_part, mail.html_part ].each { |part| assert_no_match(/Pourquoi cette campagne/, part.body.to_s) }
    end
  end

  test "invitation and Devise emails share one sender" do
    invitation = RespondentMailer.invitation(respondents(:rose))
    reset = Devise::Mailer.reset_password_instructions(managers(:alice), "token")

    assert_equal Fideback::MailerSettings.mailer_sender, invitation[:from].value
    assert_equal invitation[:from].value, reset[:from].value
  end
end
