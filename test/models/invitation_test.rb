require "test_helper"

class InvitationTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  def invite(name: "Pat Durand", email: "pat@example.com", by: managers(:alice))
    Invitation.invite(name: name, email: email, by: by)
  end

  test "inviting creates a pending invitation valid for seven days and queues the email" do
    freeze_time do
      assert_enqueued_emails 1 do
        @invitation = invite
      end

      assert @invitation.persisted?
      assert @invitation.pending?
      assert_equal 7.days.from_now, @invitation.expires_at
      assert_equal managers(:alice), @invitation.invited_by
      assert_equal 36, @invitation.token.length
    end
  end

  test "the email is stripped and lowercased" do
    assert_equal "pat@example.com", invite(email: "  Pat@Example.COM ").email
  end

  test "name and email are required and the email must look like one" do
    assert_includes invite(name: "").errors.attribute_names, :name
    assert_includes invite(email: "").errors.attribute_names, :email
    assert_includes invite(email: "pat-at-example").errors.attribute_names, :email
  end

  test "an address that already has an account is refused, whatever its case or activation" do
    pending_manager = Manager.create!(name: "Nina", email: "nina@example.com", password: "password123")
    assert_not pending_manager.confirmed?

    assert_no_enqueued_emails do
      assert_includes invite(email: "ALICE@example.com").errors.attribute_names, :email
      assert_includes invite(email: "nina@example.com").errors.attribute_names, :email
    end
    assert_equal 0, Invitation.count
  end

  test "inviting an address again replaces the previous invitation and invalidates its link" do
    first = invite
    old_token = first.token

    assert_enqueued_emails 1 do
      second = invite(name: "Patricia Durand")
      assert_equal first.id, second.id
      assert_equal "Patricia Durand", second.name
      assert_not_equal old_token, second.token
    end
    assert_equal 1, Invitation.count
    assert_nil Invitation.find_by(token: old_token)
  end

  test "an invitation expires after its validity and renewing restarts it" do
    invitation = invite
    travel 8.days do
      assert invitation.expired?
      assert_not invitation.pending?
      assert_not invitation.acceptable?

      assert invitation.renew(by: managers(:alice))
      assert invitation.pending?
      assert invitation.acceptable?
    end
  end

  test "renewing fails once the address has an account" do
    invitation = invite
    Manager.create!(name: "Pat", email: "pat@example.com", password: "password123")

    assert_not invitation.reload.acceptable?
    assert_no_enqueued_emails { assert_not invitation.renew(by: managers(:alice)) }
    assert_includes invitation.errors.attribute_names, :email
  end

  test "accepting creates an activated manager without an activation email, and consumes the invitation" do
    invitation = invite

    assert_no_emails do
      manager = invitation.accept(name: "Pat D.", password: "password123", password_confirmation: "password123")

      assert manager.persisted?
      assert manager.confirmed?
      assert manager.manager?
      assert_equal "Pat D.", manager.name
      assert_equal "pat@example.com", manager.email
    end

    assert invitation.reload.accepted?
    assert_not invitation.acceptable?
    assert_empty Invitation.unaccepted
  end

  test "accepting with a bad password creates nothing and keeps the invitation" do
    invitation = invite

    manager = invitation.accept(name: "Pat", password: "abc", password_confirmation: "abc")

    assert_not manager.persisted?
    assert_includes manager.errors.attribute_names, :password
    assert_not invitation.reload.accepted?
  end

  test "an invitation to an address registered meanwhile cannot be accepted" do
    invitation = invite
    Manager.create!(name: "Pat", email: "pat@example.com", password: "password123")

    manager = invitation.accept(name: "Pat", password: "password123", password_confirmation: "password123")

    assert_not manager.persisted?
    assert manager.errors.include?(:email)
    assert_not invitation.reload.accepted?
  end

  test "an address can be invited again after an earlier invitation was accepted and the manager removed" do
    invitation = invite
    manager = invitation.accept(name: "Pat", password: "password123", password_confirmation: "password123")
    manager.destroy!

    again = invite

    assert again.persisted?
    assert_not_equal invitation.id, again.id
  end
end
