require "test_helper"

class CampaignDeletionTest < ActionDispatch::IntegrationTest
  setup { sign_in managers(:alice) }

  def running = campaigns(:running_campaign)
  def draft = campaigns(:draft_campaign)

  def closed_campaign
    answer_fully(respondents(:rose))
    respondents(:rose).update!(submitted_at: Time.current)
    running.close!
    running
  end

  test "a draft campaign is deleted" do
    assert_difference "Campaign.count", -1 do
      delete campaign_path(draft)
    end

    assert_redirected_to campaigns_path
    assert_equal "Campagne supprimée.", flash[:notice]
  end

  test "a closed campaign is deleted with its subjects, respondents, answers and questions" do
    campaign = closed_campaign
    subject_ids = campaign.subjects.pluck(:id)
    respondent_ids = campaign.respondents.pluck(:id)
    question_ids = campaign.questions.pluck(:id)
    assert [ subject_ids, respondent_ids, question_ids ].none?(&:empty?)
    assert Answer.where(respondent_id: respondent_ids).exists?, "la campagne de départ doit avoir des réponses à supprimer"

    assert_difference "Campaign.count", -1 do
      delete campaign_path(campaign)
    end

    assert_redirected_to campaigns_path
    assert_not Subject.where(id: subject_ids).exists?
    assert_not Respondent.where(id: respondent_ids).exists?
    assert_not Question.where(id: question_ids).exists?
    assert_not Answer.where(respondent_id: respondent_ids).exists?
  end

  test "the team directory is left untouched when a campaign is deleted" do
    campaign = closed_campaign

    assert_no_difference "Contact.count" do
      delete campaign_path(campaign)
    end
  end

  test "a running campaign is refused and kept intact" do
    assert_no_difference [ "Campaign.count", "Respondent.count", "Subject.count", "Question.count" ] do
      delete campaign_path(running)
    end

    assert_redirected_to campaign_path(running)
    assert_equal "Cette campagne est en cours : clôturez-la avant de la supprimer.", flash[:alert]
    assert running.reload.running?
  end

  test "the personal link of a respondent no longer works once the campaign is deleted" do
    token = respondents(:rose).token
    campaign = closed_campaign
    get respondent_form_path(token: token)
    assert_response :success

    delete campaign_path(campaign)

    get respondent_form_path(token: token)
    assert_response :not_found
  end

  test "another manager's campaign is not found and not deleted" do
    assert_no_difference "Campaign.count" do
      delete campaign_path(campaigns(:bobs_campaign))
    end

    assert_response :not_found
  end

  test "a visitor who is not signed in is sent to the sign in page and nothing is deleted" do
    sign_out managers(:alice)

    assert_no_difference "Campaign.count" do
      delete campaign_path(draft)
    end

    assert_redirected_to new_manager_session_path
  end

  test "deleting an account deletes its campaigns whatever their state" do
    assert running.running?
    assert draft.draft?

    assert_difference "Campaign.count", -2 do
      managers(:alice).destroy
    end
  end

  def detail_of(campaign)
    css_select("form[action='#{campaign_path(campaign)}'][data-turbo-confirm]").first&.[]("data-turbo-confirm-detail")
  end

  test "the page of a draft campaign offers the delete button with the unchanged detail" do
    get campaign_path(draft)

    assert_select "form[action=?][data-turbo-confirm='Supprimer cette campagne ?'][data-turbo-confirm-tone=danger][data-turbo-confirm-icon=trash]", campaign_path(draft)
    assert_equal "Les réponses des sondés et la synthèse seront perdues. Cette action est définitive.", detail_of(draft)
  end

  test "the page of a running campaign offers no delete button" do
    get campaign_path(running)

    assert_select "form[action=?]", campaign_path(running), count: 0
    assert_select "button.btn-danger", count: 0
  end

  test "the page of a closed campaign counts the respondents who answered in the confirmation" do
    campaign = closed_campaign
    respondents(:sam).update!(submitted_at: Time.current)

    get campaign_path(campaign)

    assert_select "form[action=?][data-turbo-confirm='Supprimer cette campagne ?'][data-turbo-confirm-tone=danger]", campaign_path(campaign)
    assert_equal "Les réponses de 2 sondés sur 3 et la synthèse seront perdues. Cette action est définitive.", detail_of(campaign)
  end

  test "the confirmation of a closed campaign uses the singular for one respondent" do
    campaign = closed_campaign

    get campaign_path(campaign)

    assert_equal "La réponse de 1 sondé sur 3 et la synthèse seront perdues. Cette action est définitive.", detail_of(campaign)
  end

  test "the confirmation of a closed campaign without any answer says so" do
    running.close!

    get campaign_path(running)

    assert_equal "Aucun sondé n'a répondu. Cette action est définitive.", detail_of(running)
  end
end
