require "test_helper"

class RespondentsTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup { sign_in managers(:alice) }

  test "resend queues the invitation and stamps the date" do
    respondent = respondents(:rose)
    assert_enqueued_emails 1 do
      post resend_campaign_respondent_path(respondent.campaign, respondent)
    end
    assert_redirected_to campaign_path(respondent.campaign)
    assert_not_nil respondent.reload.last_invited_at
    follow_redirect!
    assert_select ".flash-notice", /Rose Sondée/
  end

  test "resend is refused for a respondent who already submitted" do
    respondent = respondents(:rose)
    respondent.update!(submitted_at: Time.current)
    assert_no_enqueued_emails { post resend_campaign_respondent_path(respondent.campaign, respondent) }
    assert_redirected_to campaign_path(respondent.campaign)
    assert_nil respondent.reload.last_invited_at
    follow_redirect!
    assert_select ".flash-alert"
  end

  test "resend is refused when the campaign no longer accepts answers" do
    respondent = respondents(:rose)
    campaign = respondent.campaign
    [ { status: Campaign.statuses[:closed] }, { deadline_on: Date.yesterday } ].each do |change|
      campaign.update_columns(change)
      assert_no_enqueued_emails { post resend_campaign_respondent_path(campaign, respondent) }
      assert_redirected_to campaign_path(campaign)
      campaign.update_columns(status: Campaign.statuses[:running], deadline_on: 30.days.from_now.to_date)
    end
    assert_nil respondent.reload.last_invited_at
  end

  test "resend is refused on a draft campaign" do
    respondent = respondents(:draft_rose)
    assert_no_enqueued_emails { post resend_campaign_respondent_path(respondent.campaign, respondent) }
    assert_nil respondent.reload.last_invited_at
  end

  test "another manager's respondent behaves as if it did not exist" do
    other = campaigns(:bobs_campaign).respondents.create!(name: "Zoé", email: "zoe@example.com")
    assert_no_enqueued_emails { post resend_campaign_respondent_path(other.campaign, other) }
    assert_response :not_found
    assert_nil other.reload.last_invited_at
  end

  test "a respondent id from another campaign is not found" do
    assert_no_enqueued_emails { post resend_campaign_respondent_path(campaigns(:draft_campaign), respondents(:rose)) }
    assert_response :not_found
  end
end
