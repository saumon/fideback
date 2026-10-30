require "test_helper"
require Rails.root.join("db/migrate/20261030100100_backfill_contacts_from_campaigns")

class BackfillContactsFromCampaignsTest < ActiveSupport::TestCase
  def migrate
    ActiveRecord::Migration.suppress_messages { BackfillContactsFromCampaigns.new.migrate(:up) }
  end

  setup do
    # Situation d'avant l'annuaire : des campagnes sans aucun contact.
    Subject.update_all(contact_id: nil)
    Respondent.update_all(contact_id: nil)
    Contact.delete_all
  end

  test "creates one contact per manager and email, with the latest name and the roles played" do
    older = managers(:alice).campaigns.create!(name: "Ancienne", deadline_on: 1.month.from_now.to_date)
    Subject.insert_all!([ { campaign_id: older.id, name: "Rose Ancienne", email: "ROSE@example.com",
                            created_at: 1.year.ago, updated_at: 1.year.ago } ])
    migrate

    alice = managers(:alice).contacts.index_by(&:email)
    assert_equal %w[dana@example.com eli@example.com rose@example.com sam@example.com], alice.keys.sort
    assert_equal [ true, true ], alice["dana@example.com"].values_at(:managed, :surveyable)
    assert_equal [ true, false ], alice["eli@example.com"].values_at(:managed, :surveyable)
    assert_equal [ true, true ], alice["rose@example.com"].values_at(:managed, :surveyable)
    assert_equal "Rose Sondée", alice["rose@example.com"].name
    assert_equal [ "fred@example.com" ], managers(:bob).contacts.map(&:email)

    assert_equal 0, Subject.where(contact_id: nil).count + Respondent.where(contact_id: nil).count
    assert_equal alice["rose@example.com"].id, older.subjects.sole.contact_id
    assert_equal alice["dana@example.com"].id, respondents(:dana_as_respondent).reload.contact_id
  end

  test "running it again creates no duplicate" do
    migrate
    assert_no_difference "Contact.count" do
      migrate
    end
  end
end
