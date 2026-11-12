# Une question posée aux sondés : un énoncé, et une note de 1 à 5 et/ou un commentaire.
# Commun aux questions d'une campagne et à celles d'un modèle.
module PromptWithAnswerKinds
  extend ActiveSupport::Concern

  included do
    validates :prompt, presence: true
    validate :rating_or_comment
  end

  private

  def rating_or_comment
    errors.add(:base, "Une question doit comporter une note et/ou un commentaire") unless rating? || comment?
  end
end
