require "test_helper"

class SummariesTest < ActionDispatch::IntegrationTest
  setup do
    Answer.create!(respondent: respondents(:rose), subject: subjects(:dana), question: questions(:quality), rating: 4, body: "Très bien <b>gras</b>")
    Answer.create!(respondent: respondents(:sam), subject: subjects(:dana), question: questions(:quality), rating: 2, body: "Moyen")
    Answer.create!(respondent: respondents(:sam), subject: subjects(:eli), question: questions(:quality), rating: 1, body: "Brouillon")
    respondents(:rose).update!(submitted_at: Time.current)
    respondents(:sam).update!(submitted_at: Time.current)
  end

  test "manager sees named ratings and comments, escaped" do
    sign_in managers(:alice)
    get campaign_summary_path(campaigns(:running_campaign), subject_id: subjects(:dana).id)
    assert_response :success
    assert_select "cite", text: "Rose Sondée"
    assert_select "cite", text: "Sam Sondé"
    assert_select "li", text: /Rose Sondée : 4 \/ 5/
    assert_select "strong", text: "3,0 / 5"
    assert_select "blockquote b", count: 0
    assert_includes response.body, "&lt;b&gt;gras&lt;/b&gt;"
  end

  test "campaign page links to each managé's summary once launched" do
    sign_in managers(:alice)
    get campaign_path(campaigns(:running_campaign))
    assert_select "a[href=?]", campaign_summary_path(campaigns(:running_campaign), subject_id: subjects(:dana).id)
  end

  test "another manager gets a 404" do
    sign_in managers(:bob)
    get campaign_summary_path(campaigns(:running_campaign), subject_id: subjects(:dana).id)
    assert_response :not_found
  end

  test "a subject from another campaign is a 404 even for the owner" do
    sign_in managers(:alice)
    get campaign_summary_path(campaigns(:running_campaign), subject_id: subjects(:bobs_subject).id)
    assert_response :not_found
  end

  test "a respondent cannot reach a summary through their link" do
    get campaign_summary_path(campaigns(:running_campaign), subject_id: subjects(:dana).id, token: respondents(:rose).token)
    assert_redirected_to new_manager_session_path
  end

  test "respondent form states answers are named" do
    get respondent_form_path(token: respondents(:rose).token)
    assert_select ".notice-transparency", /nominativement/
  end
end
