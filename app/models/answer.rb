class Answer < ApplicationRecord
  belongs_to :respondent
  belongs_to :subject
  belongs_to :question

  validates :rating, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, allow_nil: true
  validates :question_id, uniqueness: { scope: [ :respondent_id, :subject_id ] }
  validate :consistent_with_question

  normalizes :body, with: ->(body) { body.strip.presence }

  private

  def consistent_with_question
    return unless question

    errors.add(:rating, :present) if rating.present? && !question.rating?
    errors.add(:body, :present) if body.present? && !question.comment?
    errors.add(:base, "Le managé et la question doivent appartenir à la campagne du sondé") unless same_campaign?
  end

  def same_campaign?
    [ subject&.campaign_id, question&.campaign_id ].all? { |id| id == respondent&.campaign_id }
  end
end
