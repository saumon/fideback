class Question < ApplicationRecord
  include PromptWithAnswerKinds

  belongs_to :campaign, inverse_of: :questions
  has_many :answers, dependent: :destroy
end
