require "test_helper"

class CampaignAutoCloseTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper
  include ActiveJob::TestHelper

  # Dana est à la fois sondée et managée : elle ne se note pas elle-même.
  SUBJECTS = {
    rose: [ :dana, :eli ],
    sam: [ :dana, :eli ],
    dana_as_respondent: [ :eli ]
  }.freeze

  class BrokenDelivery
    def initialize(_settings); end

    def deliver!(_mail)
      raise "SMTP indisponible"
    end
  end

  def answers_for(name)
    SUBJECTS.fetch(name).index_by { |subject| subjects(subject).id.to_s }.transform_values do |_|
      { questions(:quality).id.to_s => { "rating" => "4", "body" => "Bien" }, questions(:strengths).id.to_s => { "body" => "Fiable" } }
    end
  end

  def submit(name)
    post submit_respondent_form_path(token: respondents(name).token), params: { answers: answers_for(name) }
  end

  def campaign = campaigns(:running_campaign)

  test "the last submission closes the campaign and the others do not" do
    submit(:rose)
    submit(:sam)
    assert campaign.reload.running?

    submit(:dana_as_respondent)

    assert campaign.reload.closed?
    assert campaign.respondents.all?(&:submitted?)
  end

  test "the last respondent sees the usual confirmation, not the closed campaign message" do
    submit(:rose)
    submit(:sam)

    submit(:dana_as_respondent)
    assert_redirected_to respondent_form_path(token: respondents(:dana_as_respondent).token)
    assert_equal "Merci ! Vos réponses ont été soumises.", flash[:notice]

    follow_redirect!
    assert_select ".callout", text: /Vous avez soumis vos réponses/
    assert_select ".callout-alert", count: 0
    assert_select "input[type=submit]", count: 0
    assert_select "button.rating-pick[disabled]"
  end

  test "coming back after the closing still shows the submission in read only" do
    submit(:rose)
    submit(:sam)
    submit(:dana_as_respondent)

    get respondent_form_path(token: respondents(:rose).token)

    assert_select ".callout", text: /Vous avez soumis vos réponses/
    assert_select ".callout-alert", count: 0
  end

  test "the manager gets one e-mail when the last respondent submits" do
    submit(:rose)
    submit(:sam)

    assert_enqueued_emails 1 do
      submit(:dana_as_respondent)
    end

    perform_enqueued_jobs
    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "alice@example.com" ], mail.to
    assert_equal "Tous vos sondés ont répondu : campagne clôturée", mail.subject
    assert_includes mail.html_part.body.to_s, "Campagne en cours"
    assert_includes mail.html_part.body.to_s, "/campaigns/#{campaign.id}"
  end

  test "the manager also gets the closing telegram message, after the submission one, when telegram is on" do
    submit(:rose)
    submit(:sam)
    configure_telegram(managers(:alice))

    assert_enqueued_emails 1 do
      assert_enqueued_jobs(2, only: TelegramMessageJob) { submit(:dana_as_respondent) }
    end

    perform_enqueued_jobs
    first, second = fake_telegram.sent_messages.map { |message| message["text"] }
    assert_includes first, "a répondu"
    assert_includes second, "Tous vos sondés ont répondu : campagne clôturée"
    assert_includes second, "« Campagne en cours »"
  end

  test "no telegram message when the manager left telegram off" do
    submit(:rose)
    submit(:sam)

    assert_no_enqueued_jobs(only: TelegramMessageJob) { submit(:dana_as_respondent) }
  end

  test "a manual closing sends no telegram message" do
    configure_telegram(managers(:alice))
    sign_in managers(:alice)

    assert_no_enqueued_jobs(only: TelegramMessageJob) { post close_campaign_path(campaign) }
  end

  test "a failing telegram message leaves the campaign closed and the e-mail sent" do
    submit(:rose)
    submit(:sam)
    configure_telegram(managers(:alice))
    fake_telegram.respond("sendMessage", status: 403, description: "Forbidden: bot was blocked by the user")
    submit(:dana_as_respondent)

    perform_enqueued_jobs

    assert campaign.reload.closed?
    assert campaign.respondents.all?(&:submitted?)
    assert_equal [ "alice@example.com" ], ActionMailer::Base.deliveries.last.to
    assert_equal 2, fake_telegram.requests_to("sendMessage").size
  end

  test "no e-mail is sent while respondents are missing" do
    assert_no_enqueued_emails { submit(:rose) }
    assert_no_enqueued_emails { submit(:sam) }
  end

  test "a manual closing sends no e-mail" do
    sign_in managers(:alice)

    assert_no_enqueued_emails { post close_campaign_path(campaign) }

    assert campaign.reload.closed?
  end

  test "a submission refused for missing ratings does not close the campaign nor send an e-mail" do
    submit(:rose)
    submit(:sam)

    assert_no_enqueued_emails do
      post submit_respondent_form_path(token: respondents(:dana_as_respondent).token), params: { answers: {} }
    end

    assert_response :unprocessable_entity
    assert campaign.reload.running?
  end

  test "a failing delivery leaves the campaign closed and the answers submitted" do
    ActionMailer::Base.add_delivery_method :broken, BrokenDelivery
    submit(:rose)
    submit(:sam)
    submit(:dana_as_respondent)
    previous = CampaignMailer.delivery_method
    CampaignMailer.delivery_method = :broken

    assert_raises(RuntimeError) { perform_enqueued_jobs }

    assert campaign.reload.closed?
    assert campaign.respondents.all?(&:submitted?)
  ensure
    CampaignMailer.delivery_method = previous if previous
  end

  test "the manager sees the status line once everyone has answered" do
    submit(:rose)
    submit(:sam)
    submit(:dana_as_respondent)
    sign_in managers(:alice)

    get campaign_path(campaign)

    assert_select ".callout", text: "Clôturée : tous les sondés ont répondu."
    assert_select "strong.status-closed", text: "Clôturée"
  end

  test "the status line is absent after a manual closing with a respondent missing" do
    sign_in managers(:alice)
    post close_campaign_path(campaign)

    get campaign_path(campaign)

    assert_select "strong.status-closed"
    assert_select ".callout", text: /tous les sondés ont répondu/, count: 0
  end

  test "the status line is absent while the campaign is running" do
    sign_in managers(:alice)

    get campaign_path(campaign)

    assert_select ".callout", text: /tous les sondés ont répondu/, count: 0
  end

  test "a manual closing after everyone answered still shows the status line" do
    campaign.respondents.update_all(submitted_at: Time.current)
    sign_in managers(:alice)
    post close_campaign_path(campaign)

    get campaign_path(campaign)

    assert_select ".callout", text: "Clôturée : tous les sondés ont répondu."
  end

  test "a running campaign whose respondents all submitted before the rule stays running" do
    campaign.respondents.update_all(submitted_at: Time.current)

    assert campaign.reload.running?
  end

  test "a submission through the form queues one telegram message for an active manager and none otherwise" do
    assert_no_enqueued_jobs(only: TelegramMessageJob) { submit(:rose) }

    configure_telegram(managers(:alice))
    assert_enqueued_jobs(1, only: TelegramMessageJob) { submit(:sam) }
  end
end
