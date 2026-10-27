class Question < ApplicationRecord
  belongs_to :campaign, inverse_of: :questions
  has_many :answers, dependent: :destroy

  validates :prompt, presence: true
  validate :rating_or_comment

  private

  def rating_or_comment
    errors.add(:base, "Une question doit comporter une note et/ou un commentaire") unless rating? || comment?
  end
end
