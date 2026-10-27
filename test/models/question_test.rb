require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  test "question without rating nor comment is refused" do
    question = campaigns(:draft_campaign).questions.build(prompt: "Vide", rating: false, comment: false)
    assert_not question.valid?
  end

  test "rating only, comment only, or both are valid" do
    [ [ true, false ], [ false, true ], [ true, true ] ].each do |rating, comment|
      assert campaigns(:draft_campaign).questions.build(prompt: "Q", rating: rating, comment: comment).valid?
    end
  end

  test "prompt is required" do
    assert_not campaigns(:draft_campaign).questions.build(prompt: "", rating: true).valid?
  end
end
