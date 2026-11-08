require "test_helper"

class ManagerNotifierTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  def campaign = campaigns(:running_campaign)

  test "campaign completed sends the e-mail only when telegram is off" do
    assert_enqueued_emails 1 do
      assert_no_enqueued_jobs(only: TelegramMessageJob) { ManagerNotifier.campaign_completed(campaign) }
    end
  end

  test "campaign completed also sends a telegram message when the manager turned it on" do
    configure_telegram(managers(:alice))

    assert_enqueued_emails 1 do
      assert_enqueued_jobs(1, only: TelegramMessageJob) { ManagerNotifier.campaign_completed(campaign) }
    end

    perform_enqueued_jobs(only: TelegramMessageJob)
    message = fake_telegram.sent_messages.sole
    count = campaign.respondents.count
    assert_equal "42", message["chat_id"]
    assert_includes message["text"], "Tous vos sondés ont répondu : campagne clôturée"
    assert_includes message["text"], "Vos #{count} sondés ont tous répondu"
    assert_includes message["text"], "« Campagne en cours »"
    assert_includes message["text"], %(<a href="http://example.com/campaigns/#{campaign.id}">Voir la synthèse</a>)
  end

  test "a configured but disabled telegram sends nothing" do
    configure_telegram(managers(:alice), enabled: false)

    assert_no_enqueued_jobs(only: TelegramMessageJob) { ManagerNotifier.campaign_completed(campaign) }
  end

  test "names typed by users are escaped so Telegram shows them as written" do
    configure_telegram(managers(:alice))
    campaign.update_columns(name: "Bilan <b>R&D</b>")

    perform_enqueued_jobs(only: TelegramMessageJob) { ManagerNotifier.campaign_completed(campaign) }

    text = fake_telegram.sent_messages.sole["text"]
    assert_includes text, "« Bilan &lt;b&gt;R&amp;D&lt;/b&gt; »"
    assert_not_includes text, "<b>R&D</b>"
  end

  test "a single respondent is worded in the singular" do
    configure_telegram(managers(:alice))
    campaign.respondents.where.not(id: respondents(:rose).id).destroy_all

    perform_enqueued_jobs(only: TelegramMessageJob) { ManagerNotifier.campaign_completed(campaign) }

    assert_includes fake_telegram.sent_messages.sole["text"], "Votre sondé a répondu"
  end
end
