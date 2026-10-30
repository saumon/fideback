require "test_helper"
require Rails.root.join("db/migrate/20261030120000_add_role_to_managers")

class AddRoleToManagersTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  def migrate(direction)
    ActiveRecord::Migration.suppress_messages { AddRoleToManagers.new.migrate(direction) }
  end

  def insert(email, created_at)
    Manager.connection.execute(
      "INSERT INTO managers (name, email, created_at, updated_at) VALUES ('#{email}', '#{email}', '#{created_at.to_fs(:db)}', '#{created_at.to_fs(:db)}')"
    )
  end

  setup do
    Manager.destroy_all
    migrate(:down)
    Manager.reset_column_information
  end

  teardown do
    migrate(:up) unless Manager.column_names.include?("role")
    Manager.reset_column_information
    Manager.destroy_all
    ActiveRecord::FixtureSet.reset_cache
    ActiveRecord::FixtureSet.create_fixtures(self.class.fixture_paths, %w[managers])
  end

  test "the oldest manager becomes admin and the others managers" do
    insert("recent@example.com", 1.day.ago)
    insert("oldest@example.com", 1.year.ago)
    insert("middle@example.com", 1.month.ago)

    migrate(:up)
    Manager.reset_column_information

    assert_equal [ [ "oldest@example.com", "admin" ], [ "middle@example.com", "manager" ], [ "recent@example.com", "manager" ] ],
                 Manager.order(:created_at).pluck(:email, :role)
  end

  test "an empty table is migrated without creating an admin" do
    migrate(:up)
    Manager.reset_column_information

    assert_equal 0, Manager.count
  end
end
