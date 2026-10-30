require "test_helper"

class ToastsTest < ActionDispatch::IntegrationTest
  setup { sign_in managers(:alice) }

  test "a notice after a redirect is a toast outside the page content" do
    post close_campaign_path(campaigns(:running_campaign))
    follow_redirect!
    assert_select "section.toasts[aria-live=polite][data-turbo-temporary] .toast.flash-notice", text: /Campagne clôturée/
    assert_select "section.toasts .toast.flash-notice[role]", count: 0
    assert_select "section.toasts button.toast-close[aria-label]"
    assert_select "main .toast", count: 0
  end

  test "an alert after a redirect is a toast with the alert role" do
    respondent = respondents(:rose)
    respondent.update!(submitted_at: Time.current)
    post resend_campaign_respondent_path(respondent.campaign, respondent)
    follow_redirect!
    assert_select "section.toasts .toast.flash-alert[role=alert]"
  end

  test "no toast region without a message" do
    get campaigns_path
    assert_select ".toasts", count: 0
  end
end
