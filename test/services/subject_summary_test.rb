require "test_helper"

class SubjectSummaryTest < ActiveSupport::TestCase
  def answer!(respondent, question, rating: nil, body: nil, subject: subjects(:dana))
    Answer.create!(respondent: respondent, subject: subject, question: question, rating: rating, body: body)
  end

  setup do
    answer!(respondents(:rose), questions(:quality), rating: 4, body: "Très bien")
    answer!(respondents(:sam), questions(:quality), rating: 5, body: "Excellent")
    answer!(respondents(:rose), questions(:strengths), body: "Fiable")
    respondents(:rose).update!(submitted_at: Time.current)
    respondents(:sam).update!(submitted_at: Time.current)
  end

  test "averages ratings and counts responses" do
    quality = SubjectSummary.new(subjects(:dana)).questions.find { |q| q.question == questions(:quality) }
    assert_equal 4.5, quality.average
    assert_equal 2, quality.rating_count
    assert_equal 2, SubjectSummary.new(subjects(:dana)).respondents_count
  end

  test "every rating and comment is attributed to its author" do
    quality = SubjectSummary.new(subjects(:dana)).questions.first
    by_name = quality.entries.to_h { |e| [ e.respondent.name, [ e.rating, e.body ] ] }
    assert_equal({ "Rose Sondée" => [ 4, "Très bien" ], "Sam Sondé" => [ 5, "Excellent" ] }, by_name)
  end

  test "unsubmitted answers are excluded" do
    answer!(respondents(:dana_as_respondent), questions(:quality), rating: 1, body: "Brouillon", subject: subjects(:eli))
    summary = SubjectSummary.new(subjects(:eli))
    assert_equal 0, summary.respondents_count
    assert summary.questions.all? { |q| q.entries.empty? }

    dana = SubjectSummary.new(subjects(:dana))
    assert_equal 2, dana.respondents_count
  end

  test "partial answers of a respondent who has not submitted do not alter averages" do
    respondents(:sam).update!(submitted_at: nil)
    quality = SubjectSummary.new(subjects(:dana)).questions.first
    assert_equal 4.0, quality.average
    assert_equal 1, quality.rating_count
  end

  test "average is nil without ratings" do
    summary = SubjectSummary.new(subjects(:eli))
    assert_nil summary.questions.first.average
  end
end
