require "test_helper"

class ManagerTest < ActiveSupport::TestCase
  test "requires a name" do
    manager = Manager.new(email: "c@example.com", password: "password123")
    assert_not manager.valid?
    assert manager.errors.of_kind?(:name, :blank)
  end

  test "email must be unique" do
    manager = Manager.new(name: "Dup", email: managers(:alice).email, password: "password123")
    assert_not manager.valid?
  end
end
