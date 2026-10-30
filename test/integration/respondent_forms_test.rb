require "test_helper"

class RespondentFormsTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  def form_path(respondent = respondents(:rose)) = respondent_form_path(token: respondent.token)
  def submit_path(respondent = respondents(:rose)) = submit_respondent_form_path(token: respondent.token)

  def full_answers(subjects: [ subjects(:dana), subjects(:eli) ])
    subjects.index_by { |s| s.id.to_s }.transform_values do |_|
      { questions(:quality).id.to_s => { "rating" => "4", "body" => "Bien" }, questions(:strengths).id.to_s => { "body" => "Fiable" } }
    end
  end

  test "launch sends one invitation per respondent with their link" do
    campaign = campaigns(:draft_campaign)
    managers(:alice)
    sign_in managers(:alice)
    assert_emails campaign.respondents.count do
      perform_enqueued_jobs { post launch_campaign_path(campaign) }
    end
    mail = ActionMailer::Base.deliveries.last
    assert_includes mail.text_part.body.to_s, campaign.respondents.first.token
  end

  test "unknown token behaves as if the page did not exist" do
    get respondent_form_path(token: "inconnu")
    assert_response :not_found
  end

  test "valid link shows managés to answer on, with the transparency notice" do
    get form_path
    assert_response :success
    assert_select "legend", text: "Dana Managée"
    assert_select "legend", text: "Eli Managé"
    assert_select ".notice-transparency", /nominativement/
  end

  test "a respondent who is also managed does not rate themself" do
    get form_path(respondents(:dana_as_respondent))
    assert_select "legend", text: "Dana Managée", count: 0
    assert_select "legend", text: "Eli Managé"
  end

  test "partial answers are saved and restored" do
    patch form_path, params: { answers: { subjects(:dana).id.to_s => { questions(:quality).id.to_s => { rating: "3", body: "Correct" } } } }
    assert_redirected_to form_path
    assert_equal 1, respondents(:rose).answers.count
    get form_path
    assert_select "input[name='answers[#{subjects(:dana).id}][#{questions(:quality).id}][rating]'][value='3']"
    assert_select "textarea", text: /Correct/
    assert_not respondents(:rose).reload.submitted?
  end

  test "rating out of range is refused" do
    [ "0", "6", "abc", "2.5" ].each do |bad|
      patch form_path, params: { answers: { subjects(:dana).id.to_s => { questions(:quality).id.to_s => { rating: bad } } } }
      assert_response :unprocessable_entity, "rating #{bad}"
    end
    assert_equal 0, respondents(:rose).answers.count
  end

  test "answers for a foreign subject or question are ignored" do
    patch form_path, params: { answers: { subjects(:bobs_subject).id.to_s => { questions(:quality).id.to_s => { rating: "5" } },
                                          subjects(:dana).id.to_s => { questions(:draft_quality).id.to_s => { rating: "5" } } } }
    assert_equal 0, Answer.count
  end

  test "final submission with all ratings locks the form" do
    post submit_path, params: { answers: full_answers }
    assert_redirected_to form_path
    assert respondents(:rose).reload.submitted?
    assert_equal :submitted, respondents(:rose).status

    get form_path
    assert_select "input[type=submit]", count: 0
    patch form_path, params: { answers: full_answers }
    assert_redirected_to form_path
    assert_equal 4, respondents(:rose).answers.count
  end

  test "final submission with missing ratings is refused and flags the fields" do
    only_dana = full_answers(subjects: [ subjects(:dana) ])
    post submit_path, params: { answers: only_dana }
    assert_response :unprocessable_entity
    assert_select ".error", text: "Note manquante"
    assert_not respondents(:rose).reload.submitted?
    assert_equal 2, respondents(:rose).answers.count # la saisie partielle est conservée
  end

  test "closed campaign refuses writes and shows a message" do
    campaigns(:running_campaign).close!
    get form_path
    assert_select ".callout-alert", /terminée/
    patch form_path, params: { answers: full_answers }
    assert_equal 0, Answer.count
    post submit_path, params: { answers: full_answers }
    assert_not respondents(:rose).reload.submitted?
  end

  test "deadline passed refuses writes" do
    campaigns(:running_campaign).update_column(:deadline_on, Date.yesterday)
    patch form_path, params: { answers: full_answers }
    assert_equal 0, Answer.count
  end

  test "a respondent cannot reach another respondent's answers" do
    post submit_path(respondents(:sam)), params: { answers: full_answers }
    assert respondents(:sam).reload.submitted?
    assert_not respondents(:rose).reload.submitted?
    assert_equal 0, respondents(:rose).answers.count
  end
end
