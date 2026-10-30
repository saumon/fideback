require "test_helper"

class ContactTest < ActiveSupport::TestCase
  def build(attrs = {})
    managers(:alice).contacts.build({ name: "Nina", email: "nina@example.com", managed: true }.merge(attrs))
  end

  test "valid with a name, an email and a role" do
    assert build.valid?
  end

  test "email is normalized" do
    assert_equal "nina@example.com", build(email: "  NINA@Example.com ").email
  end

  test "email must be unique within the directory, case insensitively" do
    contact = build(email: "DANA@example.com")
    assert_not contact.valid?
    assert contact.errors.of_kind?(:email, :taken)
  end

  test "same email is allowed in another manager's directory" do
    assert managers(:bob).contacts.build(name: "Dana", email: "dana@example.com", surveyable: true).valid?
  end

  test "name and a well-formed email are required" do
    contact = build(name: "", email: "pas-un-email")
    assert_not contact.valid?
    assert contact.errors.of_kind?(:name, :blank)
    assert contact.errors.of_kind?(:email, :invalid)
  end

  test "at least one role is required" do
    contact = build(managed: false, surveyable: false)
    assert_not contact.valid?
    assert_match "managé, sondable ou les deux", contact.errors.full_messages.to_sentence
  end

  test "renaming a contact updates its copies in draft campaigns only" do
    contacts(:dana).update!(name: "Dana Renommée", email: "dana.r@example.com")
    assert_equal [ "Dana Renommée", "dana.r@example.com" ], subjects(:draft_dana).reload.values_at(:name, :email)
    assert_equal [ "Dana Managée", "dana@example.com" ], subjects(:dana).reload.values_at(:name, :email)
    assert_equal "Dana Managée", respondents(:dana_as_respondent).reload.name
  end

  test "removing a role removes the matching copies from draft campaigns" do
    draft_subject, draft_respondent = subjects(:draft_dana), respondents(:draft_rose)
    contacts(:dana).update!(managed: false)
    assert_not Subject.exists?(draft_subject.id)
    assert Subject.exists?(subjects(:dana).id)

    contacts(:rose).update!(surveyable: false, managed: true)
    assert_not Respondent.exists?(draft_respondent.id)
    assert Respondent.exists?(respondents(:rose).id)
  end

  test "destroying a contact removes it from drafts and detaches launched copies untouched" do
    answer = Answer.create!(respondent: respondents(:sam), subject: subjects(:dana), question: questions(:strengths), body: "Bien")
    token = respondents(:dana_as_respondent).token
    draft_subject = subjects(:draft_dana)
    contacts(:dana).destroy!

    assert_not Subject.exists?(draft_subject.id)
    launched = subjects(:dana).reload
    assert_nil launched.contact_id
    assert_equal "Dana Managée", launched.name
    assert_equal token, respondents(:dana_as_respondent).reload.token
    assert Answer.exists?(answer.id)
  end
end
