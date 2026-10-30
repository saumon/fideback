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
    assert_select "[data-nested-form-target=container] input[name$='[prompt]']", count: Campaign::DEFAULT_QUESTIONS.size
    assert_select "input[value='#{Campaign::DEFAULT_QUESTIONS.first[:prompt]}']"
  end

  test "new form has one blank subject row and one blank respondent row, plus a template for each list" do
    get new_campaign_path
    assert_select "[data-nested-form-target=container] input[name$='[name]'][placeholder=Nom]", count: 2
    assert_select "template[data-nested-form-target=template]", count: 3
    assert_select "template input[name='campaign[questions_attributes][NEW_RECORD][prompt]']"
    assert_select "button[data-action='nested-form#add']", count: 3
  end

  test "edit form shows existing items, a delete button on each and one blank contact row" do
    campaign = campaigns(:draft_campaign)
    get edit_campaign_path(campaign)
    assert_select "[data-nested-form-target=container] .question", count: campaign.questions.count
    assert_select "[data-nested-form-target=container] .contact[data-new-record=false]", count: campaign.subjects.count + campaign.respondents.count
    assert_select "[data-nested-form-target=container] .contact[data-new-record=true]", count: 2
    assert_select "[data-nested-form-target=container] button", text: "Supprimer", minimum: campaign.questions.count
  end

  test "create with added items, a default question left out and blank rows ignored" do
    post campaigns_path, params: { campaign: {
      name: "Dynamique", deadline_on: 20.days.from_now.to_date,
      subjects_attributes: { "1700000000001" => { name: "Gina", email: "gina@example.com", _destroy: "0" },
                             "1700000000002" => { name: "Ivan", email: "ivan@example.com", _destroy: "0" },
                             "1700000000003" => { name: "", email: "", _destroy: "0" } },
      respondents_attributes: { "0" => { name: "Hugo", email: "hugo@example.com", _destroy: "0" } },
      questions_attributes: { "1" => { prompt: "Première", rating: "1", comment: "0", _destroy: "0" },
                              "2" => { prompt: "Seconde", rating: "0", comment: "1", _destroy: "0" } }
    } }
    campaign = Campaign.order(:id).last
    assert_redirected_to campaign_path(campaign)
    assert_equal %w[Gina Ivan], campaign.subjects.order(:id).map(&:name)
    assert_equal [ [ "Première", 0 ], [ "Seconde", 1 ] ], campaign.questions.map { |q| [ q.prompt, q.position ] }
  end

  test "update adds a question and removes a persisted one" do
    campaign = campaigns(:draft_campaign)
    existing = campaign.questions.first
    patch campaign_path(campaign), params: { campaign: {
      questions_attributes: { "0" => { id: existing.id, prompt: existing.prompt, rating: "1", comment: "1", _destroy: "1" },
                              "1700000000001" => { prompt: "Ajoutée", rating: "1", comment: "0", _destroy: "0" } },
      subjects_attributes: { "0" => { id: campaign.subjects.first.id, _destroy: "1" } }
    } }
    assert_redirected_to campaign_path(campaign)
    campaign.reload
    assert_not_includes campaign.questions, existing
    assert_equal "Ajoutée", campaign.questions.last.prompt
    assert_equal (0...campaign.questions.size).to_a, campaign.questions.map(&:position)
    assert_equal 0, campaign.subjects.count
  end

  test "a failed create keeps added rows, drops removed ones and does not pile up blank rows" do
    post campaigns_path, params: { campaign: {
      name: "", deadline_on: 20.days.from_now.to_date,
      subjects_attributes: { "5" => { name: "Gina", email: "gina@example.com", _destroy: "0" } },
      questions_attributes: { "7" => { prompt: "Seule question", rating: "1", comment: "0", _destroy: "0" } }
    } }
    assert_response :unprocessable_entity
    assert_select "[data-nested-form-target=container] input[value='Gina']", count: 1
    assert_select "[data-nested-form-target=container] .question", count: 1
    assert_select "[data-nested-form-target=container] input[value='Seule question']"
    assert_select "[data-nested-form-target=container] .contact[data-new-record=true]", count: 2 # Gina + une ligne vide de sondé
  end

  test "a failed update re-renders a persisted item marked for deletion as hidden" do
    campaign = campaigns(:draft_campaign)
    subject = campaign.subjects.first
    patch campaign_path(campaign), params: { campaign: {
      name: "",
      subjects_attributes: { "0" => { id: subject.id, name: subject.name, email: subject.email, _destroy: "1" } }
    } }
    assert_response :unprocessable_entity
    assert_select ".contact[hidden] input[name$='[_destroy]'][value='1']"
    assert_equal subject, subject.reload
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
    assert_select "main form .callout-alert li"
    assert_select ".toasts", count: 0
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
