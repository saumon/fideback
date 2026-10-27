require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  def build(**attrs)
    Answer.new({ respondent: respondents(:rose), subject: subjects(:dana), question: questions(:quality), rating: 4 }.merge(attrs))
  end

  test "valid rating answer" do
    assert build.valid?
  end

  test "rating must be an integer between 1 and 5" do
    [ 0, 6, -1 ].each { |rating| assert_not build(rating: rating).valid?, "rating #{rating}" }
    (1..5).each { |rating| assert build(rating: rating).valid?, "rating #{rating}" }
  end

  test "one answer per respondent, subject and question" do
    build.save!
    assert_not build(rating: 2).valid?
  end

  test "rating is refused on a comment-only question" do
    assert_not build(question: questions(:strengths), rating: 3).valid?
  end

  test "comment is refused on a rating-only question" do
    question = campaigns(:running_campaign).questions.create!(prompt: "Note seule", rating: true, comment: false, position: 5)
    assert_not build(question: question, body: "texte").valid?
  end

  test "blank comment is stored as nil" do
    answer = build(question: questions(:strengths), rating: nil, body: "  ")
    assert answer.valid?
    assert_nil answer.body
  end

  test "subject and question must belong to the respondent's campaign" do
    assert_not build(subject: subjects(:bobs_subject)).valid?
    assert_not build(question: questions(:draft_quality)).valid?
  end
end
