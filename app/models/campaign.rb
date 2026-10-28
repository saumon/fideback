class Campaign < ApplicationRecord
  DEFAULT_QUESTIONS = [
    { prompt: "Qualité du travail réalisé cette année", rating: true, comment: true },
    { prompt: "Collaboration et esprit d'équipe", rating: true, comment: true },
    { prompt: "Points forts à valoriser", rating: false, comment: true },
    { prompt: "Axes de progrès", rating: false, comment: true }
  ].freeze

  belongs_to :manager
  has_many :subjects, dependent: :destroy
  has_many :respondents, dependent: :destroy
  has_many :questions, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :campaign

  accepts_nested_attributes_for :subjects, :respondents, :questions, allow_destroy: true,
                                reject_if: ->(attrs) { attrs.values_at("name", "email", "prompt").all?(&:blank?) }

  enum :status, { draft: 0, running: 1, closed: 2 }, default: :draft

  validates :name, :deadline_on, presence: true
  validate :deadline_in_future, on: :create
  validate :content_frozen_once_launched, on: :update

  before_validation :renumber_questions, if: :draft?

  def build_default_questions
    DEFAULT_QUESTIONS.each_with_index do |attrs, index|
      questions.build(attrs.merge(position: index))
    end
  end

  def launch!
    raise ActiveRecord::RecordInvalid, self unless launchable?

    transaction do
      running!
      respondents.each(&:invite!)
    end
  end

  def close!
    unless running?
      errors.add(:base, "La campagne n'est pas en cours")
      raise ActiveRecord::RecordInvalid, self
    end

    closed!
  end

  def accepting_answers?
    running? && deadline_on >= Date.current
  end

  def launchable?
    errors.clear
    errors.add(:base, "La campagne a déjà été lancée") unless draft?
    errors.add(:subjects, :blank) if subjects.reject(&:marked_for_destruction?).empty?
    errors.add(:respondents, :blank) if respondents.reject(&:marked_for_destruction?).empty?
    errors.add(:questions, :blank) if questions.reject(&:marked_for_destruction?).empty?
    errors.empty?
  end

  private

  def renumber_questions
    return unless questions.any?(&:changed_for_autosave?)

    questions.reject(&:marked_for_destruction?).each_with_index do |question, index|
      question.position = index
    end
  end

  def deadline_in_future
    errors.add(:deadline_on, :greater_than, count: Date.current) if deadline_on && deadline_on <= Date.current
  end

  def content_frozen_once_launched
    return if status_changed? || draft?

    frozen_change = subjects.any?(&:changed_for_autosave?) || respondents.any?(&:changed_for_autosave?) ||
                    questions.any?(&:changed_for_autosave?)
    errors.add(:base, "Les managés, sondés et questions ne sont plus modifiables après le lancement") if frozen_change
  end
end
