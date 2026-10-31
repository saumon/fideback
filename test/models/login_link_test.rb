require "test_helper"

class LoginLinkTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup { @manager = managers(:bob) }

  test "issuing a link creates a usable one valid for ten minutes and queues the email" do
    freeze_time do
      link = nil
      assert_enqueued_emails 1 do
        link = LoginLink.issue_for(@manager)
      end

      assert link.persisted?
      assert link.usable?
      assert_equal 10.minutes.from_now, link.expires_at
      assert_equal 36, link.token.length
      assert_equal @manager, link.manager
    end
  end

  test "a link is usable once only" do
    link = LoginLink.issue_for(@manager)

    assert link.consume!
    assert_not link.reload.usable?
    assert_not link.consume!
  end

  test "a link is no longer usable after ten minutes" do
    link = LoginLink.issue_for(@manager)

    travel 10.minutes + 1.second do
      assert_not link.usable?
      assert_not link.consume!
    end
  end

  test "a new link replaces the previous ones once the delay is over" do
    first = LoginLink.issue_for(@manager)

    travel 61.seconds do
      second = LoginLink.issue_for(@manager)

      assert second
      assert_nil LoginLink.find_by(id: first.id)
      assert_equal [ second ], @manager.login_links.to_a
    end
  end

  test "no email is sent when a link left less than a minute ago, and the first stays valid" do
    first = LoginLink.issue_for(@manager)

    travel 30.seconds do
      assert_no_enqueued_emails do
        assert_nil LoginLink.issue_for(@manager)
      end
      assert first.reload.usable?
      assert_includes 30..31, LoginLink.cooldown_remaining(@manager)
    end
  end

  test "the delay is over after a minute" do
    LoginLink.issue_for(@manager)

    travel 61.seconds do
      assert_equal 0, LoginLink.cooldown_remaining(@manager)
    end
  end

  test "links belong to a single manager" do
    LoginLink.issue_for(@manager)
    other = LoginLink.issue_for(managers(:alice))

    assert_equal 2, LoginLink.count
    assert_equal [ other ], managers(:alice).login_links.to_a
  end

  test "expired links are dropped when a new one is issued" do
    old = LoginLink.issue_for(@manager)

    travel 11.minutes do
      LoginLink.issue_for(@manager)
      assert_nil LoginLink.find_by(id: old.id)
    end
  end

  test "deleting the manager deletes the links" do
    LoginLink.issue_for(@manager)

    assert_difference "LoginLink.count", -1 do
      @manager.destroy
    end
  end
end
