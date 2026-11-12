class QuestionTemplateItem < ApplicationRecord
  include PromptWithAnswerKinds

  belongs_to :question_template, inverse_of: :items

  # Les questions du modèle du système suivent celui-ci : elles ne se modifient pas non plus.
  def readonly?
    super || (persisted? && question_template&.system?) || false
  end

  # Les attributs d'une question de campagne, pour la construire à partir du modèle.
  def question_attributes
    slice(:position, :prompt, :rating, :comment)
  end
end
