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

  test "selecting contacts copies them into the campaign, unselecting removes the copy" do
    campaign = campaigns(:draft_campaign)
    assert campaign.update(subject_contact_ids: [ contacts(:eli).id.to_s ], respondent_contact_ids: [ "", contacts(:rose).id, contacts(:sam).id ])
    campaign.reload
    assert_equal [ [ "Eli Managé", "eli@example.com", contacts(:eli).id ] ], campaign.subjects.map { |s| [ s.name, s.email, s.contact_id ] }
    assert_equal [ respondents(:draft_rose).id ], campaign.respondents.where(contact: contacts(:rose)).ids # copie existante gardée
    assert_equal 2, campaign.respondents.count
    assert contacts(:dana).reload.persisted?
  end

  test "a contact without the list's role or from another manager is ignored" do
    campaign = campaigns(:draft_campaign)
    assert campaign.update(subject_contact_ids: [ contacts(:rose).id, contacts(:fred).id, contacts(:dana).id ])
    assert_equal [ contacts(:dana).id ], campaign.reload.subjects.map(&:contact_id)
  end

  test "a new contact joins the directory with the list's role and is selected" do
    campaign = managers(:alice).campaigns.build(name: "Nouvelle", deadline_on: 1.month.from_now.to_date)
    campaign.new_respondent_contacts = { "1" => { name: "Nina", email: " NINA@example.com" }, "2" => { name: "", email: "" } }
    assert_difference "Contact.count", 1 do
      assert campaign.save
    end
    nina = managers(:alice).contacts.find_by!(email: "nina@example.com")
    assert nina.surveyable?
    assert_not nina.managed?
    assert_equal [ nina.id ], campaign.respondents.map(&:contact_id)
  end

  test "a new contact whose email is already in the directory reuses it and gains the role" do
    campaign = campaigns(:draft_campaign)
    assert_no_difference "Contact.count" do
      assert campaign.update(subject_contact_ids: [ contacts(:dana).id ],
                             new_subject_contacts: [ { name: "Rose bis", email: "ROSE@example.com" } ])
    end
    rose = contacts(:rose).reload
    assert rose.managed?
    assert_equal "Rose Sondée", rose.name
    assert_equal [ contacts(:dana).id, rose.id ].sort, campaign.reload.subjects.map(&:contact_id).sort
  end

  test "an invalid new contact saves neither the campaign nor the directory" do
    campaign = campaigns(:draft_campaign)
    assert_no_difference [ "Contact.count", "Subject.count" ] do
      assert_not campaign.update(name: "Renommée", subject_contact_ids: [],
                                 new_subject_contacts: [ { name: "Nina", email: "nina@example.com" }, { name: "", email: "pas-un-email" } ])
    end
    assert_match "Nouveau contact « pas-un-email »", campaign.errors.full_messages.to_sentence
    assert_equal [ "nina@example.com", "pas-un-email" ], campaign.new_subject_contacts.map(&:email)
    assert_equal "Entretiens 2026", campaign.reload.name
  end

  test "content cannot be edited once launched" do
    campaign = campaigns(:running_campaign)
    assert_not campaign.update(subject_contact_ids: [ contacts(:dana).id ])
    assert campaign.errors[:base].any?
    assert_not campaign.update(questions_attributes: [ { id: questions(:quality).id, prompt: "Autre" } ])
  end

  test "name can still be edited once launched" do
    assert campaigns(:running_campaign).update(name: "Renommée")
  end

  test "all_submitted? is false while a respondent has not submitted" do
    campaign = campaigns(:running_campaign)
    assert_not campaign.all_submitted?

    campaign.respondents.each { |respondent| respondent.update!(submitted_at: Time.current) }
    assert campaign.all_submitted?
  end

  test "all_submitted? reads the database, not a loaded association" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.load
    campaign.respondents.update_all(submitted_at: Time.current)

    assert campaign.all_submitted?
  end

  test "close_when_complete! closes a running campaign once everyone submitted" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.update_all(submitted_at: Time.current)

    assert campaign.close_when_complete!
    assert campaign.closed?
    assert campaigns(:running_campaign).reload.closed?
    assert_not campaign.accepting_answers?
  end

  test "close_when_complete! leaves the campaign running while a respondent is missing" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:sam).id).update_all(submitted_at: Time.current)

    assert_not campaign.close_when_complete!
    assert campaign.reload.running?
  end

  test "saved answers without a final submission do not count" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:sam).id).update_all(submitted_at: Time.current)
    answer_fully(respondents(:sam))

    assert_not campaign.close_when_complete!
    assert campaign.reload.running?
  end

  test "a campaign with one respondent closes on that submission" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.where.not(id: respondents(:rose).id).destroy_all
    campaign.respondents.reload.update_all(submitted_at: Time.current)

    assert campaign.close_when_complete!
  end

  test "close_when_complete! does nothing on a draft or an already closed campaign" do
    assert_not campaigns(:draft_campaign).close_when_complete!

    campaign = campaigns(:running_campaign)
    campaign.respondents.update_all(submitted_at: Time.current)
    assert campaign.close_when_complete!
    assert_not campaign.close_when_complete!
  end

  test "only one of two competing closings succeeds" do
    campaign = campaigns(:running_campaign)
    campaign.respondents.update_all(submitted_at: Time.current)
    other = Campaign.find(campaign.id)

    results = [ campaign.close_when_complete!, other.close_when_complete! ]

    assert_equal [ true, false ], results
    assert campaign.reload.closed?
  end
end
