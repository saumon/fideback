require "test_helper"

class CampaignMailerTest < ActionMailer::TestCase
  test "completed tells the manager every respondent answered and links to the campaign" do
    campaign = campaigns(:running_campaign)
    mail = CampaignMailer.completed(campaign)

    assert_equal [ "alice@example.com" ], mail.to
    assert_equal "Tous vos sondés ont répondu : campagne clôturée", mail.subject
    [ mail.text_part, mail.html_part ].each do |part|
      body = part.body.to_s
      assert_includes body, "Bonjour Alice Manager,"
      assert_includes body, "Campagne en cours"
      assert_includes body, "3 sondés"
      assert_includes body, "/campaigns/#{campaign.id}"
    end
    assert_includes mail.html_part.body.to_s, "Voir la synthèse"
  end

  test "completed uses the common sender and the shared layout" do
    mail = CampaignMailer.completed(campaigns(:running_campaign))

    assert_equal Fideback::MailerSettings.mailer_sender, mail[:from].value
    assert_includes mail.html_part.body.to_s, "Fideback"
    assert_includes mail.html_part.body.to_s, "border: 2px solid #231942"
  end

  test "completed names a single respondent in the singular" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:rose).id).destroy_all

    assert_includes CampaignMailer.completed(campaign.reload).text_part.body.to_s, "La réponse de votre sondé est soumise"
  end
end
