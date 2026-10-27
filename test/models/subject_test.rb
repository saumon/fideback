require "test_helper"

class SubjectTest < ActiveSupport::TestCase
  test "email must be unique within a campaign, case insensitively" do
    subject = campaigns(:running_campaign).subjects.build(name: "Doublon", email: "DANA@example.com")
    assert_not subject.valid?
  end

  test "same email is allowed in another campaign" do
    subject = campaigns(:bobs_campaign).subjects.build(name: "Dana", email: "dana@example.com")
    assert subject.valid?
  end
end
