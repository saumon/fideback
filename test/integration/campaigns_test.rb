require "test_helper"

class CampaignsTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup { sign_in managers(:alice) }

  test "index lists only my campaigns" do
    get campaigns_path
    assert_response :success
    assert_select "a", text: "Entretiens 2026"
    assert_select "a", text: "Campagne de Bob", count: 0
  end

  test "new form is prefilled with default questions" do
    get new_campaign_path
    assert_response :success
    assert_select "input[name$='[prompt]']", count: Campaign::DEFAULT_QUESTIONS.size
    assert_select "input[value='#{Campaign::DEFAULT_QUESTIONS.first[:prompt]}']"
  end

  test "create a valid campaign" do
    assert_difference "Campaign.count", 1 do
      post campaigns_path, params: { campaign: {
        name: "Fin d'année", deadline_on: 20.days.from_now.to_date,
        subjects_attributes: { "0" => { name: "Gina", email: "gina@example.com" }, "1" => { name: "", email: "" } },
        respondents_attributes: { "0" => { name: "Hugo", email: "hugo@example.com" } },
        questions_attributes: { "0" => { prompt: "Note globale", rating: "1", comment: "0", position: 0 } }
      } }
    end
    campaign = Campaign.order(:id).last
    assert_redirected_to campaign_path(campaign)
    assert_equal managers(:alice), campaign.manager
    assert campaign.draft?
    assert_equal 1, campaign.subjects.count
  end

  test "create with a missing name re-renders the form" do
    assert_no_difference "Campaign.count" do
      post campaigns_path, params: { campaign: { name: "", deadline_on: 20.days.from_now.to_date } }
    end
    assert_response :unprocessable_entity
  end

  test "another manager's campaign behaves as if it did not exist" do
    other = campaigns(:bobs_campaign)
    [
      [ :get, campaign_path(other) ],
      [ :patch, campaign_path(other), { campaign: { name: "Piratée" } } ],
      [ :post, launch_campaign_path(other) ],
      [ :delete, campaign_path(other) ]
    ].each do |verb, path, params|
      sign_in managers(:alice) # la session de test n'est pas conservée après une 404
      send(verb, path, params: params)
      assert_response :not_found, "#{verb} #{path}"
    end
    assert_equal "Campagne de Bob", other.reload.name
    assert other.draft?
  end

  test "launching sends invitations and freezes editing" do
    campaign = campaigns(:draft_campaign)
    assert_enqueued_emails campaign.respondents.count do
      post launch_campaign_path(campaign)
    end
    assert_redirected_to campaign_path(campaign)
    assert campaign.reload.running?
    get edit_campaign_path(campaign)
    assert_redirected_to campaign_path(campaign)
  end

  test "launching without respondents is refused" do
    campaign = campaigns(:draft_campaign)
    campaign.respondents.destroy_all
    assert_no_enqueued_emails { post launch_campaign_path(campaign) }
    assert campaign.reload.draft?
    follow_redirect!
    assert_select ".flash-alert"
  end

  test "closing a running campaign" do
    post close_campaign_path(campaigns(:running_campaign))
    assert campaigns(:running_campaign).reload.closed?
  end

  test "show displays each respondent status and the response rate" do
    campaign = campaigns(:running_campaign)
    respondents(:rose).update!(submitted_at: Time.current)
    answers = Answer.create!(respondent: respondents(:sam), subject: subjects(:dana), question: questions(:strengths), body: "Super")
    get campaign_path(campaign)
    assert_response :success
    assert_select "#response-rate", /1 \/ 3 réponses soumises/
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:rose))}", /A répondu/
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:sam))}", /Réponse partielle/
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:dana_as_respondent))}", /Pas encore répondu/
  end

  test "show offers a resend button only to respondents who can still answer" do
    respondents(:rose).update!(submitted_at: Time.current)
    respondents(:sam).update!(last_invited_at: Time.zone.local(2026, 10, 20, 9, 30))
    get campaign_path(campaigns(:running_campaign))
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:rose))} form", count: 0
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:sam))} form[action='#{resend_campaign_respondent_path(campaigns(:running_campaign), respondents(:sam))}']"
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:sam))}", /20 oct\./
    assert_select "##{ActionView::RecordIdentifier.dom_id(respondents(:dana_as_respondent))}", /—/
  end

  test "show has no resend button outside a running campaign" do
    get campaign_path(campaigns(:draft_campaign))
    assert_select "button", text: "Renvoyer", count: 0
    assert_select "th", text: "Invité le"
  end
end
