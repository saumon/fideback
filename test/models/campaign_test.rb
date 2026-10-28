require "test_helper"

class CampaignTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper
  test "valid campaign starts as draft" do
    campaign = managers(:alice).campaigns.build(name: "Nouvelle", deadline_on: 10.days.from_now.to_date)
    assert campaign.valid?
    assert campaign.draft?
  end

  test "requires a future deadline on creation" do
    campaign = managers(:alice).campaigns.build(name: "Passée", deadline_on: Date.current)
    assert_not campaign.valid?
    assert campaign.errors.key?(:deadline_on)
  end

  test "default questions are built with rating and/or comment" do
    campaign = Campaign.new
    campaign.build_default_questions
    assert_equal Campaign::DEFAULT_QUESTIONS.size, campaign.questions.size
    assert campaign.questions.all? { |q| q.rating? || q.comment? }
  end

  test "questions are renumbered in form order, ignoring those marked for destruction" do
    campaign = campaigns(:draft_campaign)
    first, second = campaign.questions.to_a.first(2)
    campaign.update!(questions_attributes: [
      { id: first.id, _destroy: "1" },
      { prompt: "Nouvelle", rating: "1", comment: "0" }
    ])
    positions = campaign.reload.questions.map(&:position)
    assert_equal (0...positions.size).to_a, positions
    assert_not_includes campaign.questions, first
    assert_equal "Nouvelle", campaign.questions.last.prompt
  end

  test "launch! refuses a campaign without respondents" do
    campaign = campaigns(:draft_campaign)
    campaign.respondents.destroy_all
    campaign.reload
    assert_raises(ActiveRecord::RecordInvalid) { campaign.launch! }
    assert campaign.reload.draft?
  end

  test "launch! refuses a campaign without subjects" do
    campaign = campaigns(:draft_campaign)
    campaign.subjects.destroy_all
    campaign.reload
    assert_raises(ActiveRecord::RecordInvalid) { campaign.launch! }
    assert campaign.reload.draft?
  end

  test "launch! moves to running and sends one invitation per respondent" do
    campaign = campaigns(:draft_campaign)
    assert_enqueued_emails campaign.respondents.count do
      campaign.launch!
    end
    assert campaign.reload.running?
    assert campaign.respondents.all?(&:last_invited_at)
  end

  test "close! only works on a running campaign" do
    assert_raises(ActiveRecord::RecordInvalid) { campaigns(:draft_campaign).close! }
    campaigns(:running_campaign).close!
    assert campaigns(:running_campaign).reload.closed?
  end

  test "accepting_answers? depends on status and deadline" do
    campaign = campaigns(:running_campaign)
    assert campaign.accepting_answers?
    campaign.deadline_on = Date.yesterday
    assert_not campaign.accepting_answers?
    campaign.deadline_on = Date.tomorrow
    campaign.status = :closed
    assert_not campaign.accepting_answers?
  end

  test "content cannot be edited once launched" do
    campaign = campaigns(:running_campaign)
    assert_not campaign.update(subjects_attributes: [ { name: "Nouveau", email: "nouveau@example.com" } ])
    assert campaign.errors[:base].any?
    assert_not campaign.update(questions_attributes: [ { id: questions(:quality).id, prompt: "Autre" } ])
  end

  test "name can still be edited once launched" do
    assert campaigns(:running_campaign).update(name: "Renommée")
  end
end
