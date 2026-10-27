# Synthèse nominative des feedbacks reçus sur un managé (soumissions finales uniquement).
class SubjectSummary
  Entry = Struct.new(:respondent, :rating, :body, keyword_init: true)
  QuestionSummary = Struct.new(:question, :entries, keyword_init: true) do
    def ratings = entries.filter_map(&:rating)
    def average = ratings.empty? ? nil : (ratings.sum.to_f / ratings.size).round(1)
    def rating_count = ratings.size
    def comments = entries.select { |entry| entry.body.present? }
  end

  attr_reader :subject

  def initialize(subject)
    @subject = subject
    @campaign = subject.campaign
  end

  def respondents_count
    submitted_answers.map(&:respondent_id).uniq.size
  end

  def questions
    @questions ||= @campaign.questions.map do |question|
      entries = submitted_answers.select { |answer| answer.question_id == question.id }
                                 .sort_by { |answer| answer.respondent.name.downcase }
                                 .map { |answer| Entry.new(respondent: answer.respondent, rating: answer.rating, body: answer.body) }
      QuestionSummary.new(question: question, entries: entries)
    end
  end

  private

  def submitted_answers
    @submitted_answers ||= subject.answers
                                  .joins(:respondent).merge(Respondent.where.not(submitted_at: nil))
                                  .includes(:respondent).to_a
  end
end
