require "test_helper"

class RespondentTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

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

  test "invitable? only for a pending respondent of a campaign still accepting answers" do
    assert respondents(:rose).invitable?
    assert_not respondents(:draft_rose).invitable?

    respondents(:rose).update!(submitted_at: Time.current)
    assert_not respondents(:rose).invitable?

    campaigns(:running_campaign).update_columns(deadline_on: Date.yesterday)
    assert_not respondents(:sam).reload.invitable?

    campaigns(:running_campaign).update_columns(deadline_on: 5.days.from_now.to_date, status: Campaign.statuses[:closed])
    assert_not respondents(:sam).reload.invitable?
  end

  test "invite! stamps last_invited_at and enqueues the invitation" do
    respondent = respondents(:rose)
    assert_nil respondent.last_invited_at
    assert_enqueued_emails 1 do
      freeze_time { respondent.invite!; assert_equal Time.current, respondent.reload.last_invited_at }
    end
  end

  test "the last submission closes the campaign" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:sam).id).update_all(submitted_at: Time.current)

    submit_fully(respondents(:sam))

    assert campaign.reload.closed?
    assert respondents(:sam).reload.submitted?
  end

  test "a submission with respondents left keeps the campaign running" do
    submit_fully(respondents(:rose))

    assert campaigns(:running_campaign).reload.running?
  end

  test "a submission refused for missing ratings does not close the campaign" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:sam).id).update_all(submitted_at: Time.current)

    assert_not respondents(:sam).submit!

    assert campaign.reload.running?
    assert_not respondents(:sam).reload.submitted?
  end

  test "a submission after the deadline is refused and does not close the campaign" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:sam).id).update_all(submitted_at: Time.current)
    answer_fully(respondents(:sam))
    campaign.update_columns(deadline_on: Date.yesterday)

    assert_not respondents(:sam).reload.submit!

    assert campaign.reload.running?
  end
end
