require "test_helper"

class AdminUsersHelperTest < ActionView::TestCase
  test "the manager deletion detail counts the campaigns lost" do
    assert_equal "Il n'a aucune campagne. Cette action est définitive.", delete_manager_detail(0)
    assert_equal "Sa campagne et toutes les réponses recueillies seront effacées. Cette action est définitive.", delete_manager_detail(1)
    assert_equal "Ses 3 campagnes et toutes les réponses recueillies seront effacées. Cette action est définitive.", delete_manager_detail(3)
  end
end
