# Un jeu de questions réutilisable pour démarrer une campagne. Le modèle du système (system: true, sans manager) est
# fourni à tous et ne change pas ; les autres appartiennent chacun à un manager. Une campagne en copie les questions
# et n'a ensuite plus aucun lien avec le modèle.
class QuestionTemplate < ApplicationRecord
  belongs_to :manager, optional: true
  has_many :items, -> { order(:position, :id) }, class_name: "QuestionTemplateItem", dependent: :destroy, inverse_of: :question_template

  accepts_nested_attributes_for :items, allow_destroy: true, reject_if: ->(attrs) { attrs["prompt"].blank? }

  validates :name, presence: true
  validate :needs_a_question

  before_validation :renumber_items

  # Le modèle du système en premier, puis ceux du manager par nom.
  scope :available_to, ->(manager) { where(system: true).or(where(manager: manager)).order(system: :desc, name: :asc, id: :asc) }

  # Le modèle du système tel que le crée la migration (qui en garde sa propre copie, figée) et les seeds, pour les bases
  # créées depuis le schéma, où aucune migration ne passe.
  DEFAULT_NAME = "Modèle par défaut".freeze
  DEFAULT_ITEMS = [
    { prompt: "Qualité du travail réalisé cette année", rating: true, comment: true },
    { prompt: "Collaboration et esprit d'équipe", rating: true, comment: true },
    { prompt: "Points forts à valoriser", rating: false, comment: true },
    { prompt: "Axes de progrès", rating: false, comment: true }
  ].freeze

  def self.default
    find_by!(system: true)
  end

  # Idempotent : un modèle du système déjà présent n'est jamais recréé ni modifié.
  def self.ensure_default!
    find_by(system: true) || create!(name: DEFAULT_NAME, system: true, items_attributes: DEFAULT_ITEMS)
  end

  # Ni modification ni suppression du modèle du système (save, update, destroy lèvent ReadOnlyRecord).
  def readonly?
    super || (persisted? && system?) || false
  end

  # Les questions d'une nouvelle campagne, copiées de ce modèle.
  def build_questions_for(campaign)
    items.each { |item| campaign.questions.build(item.question_attributes) }
  end

  private

  def needs_a_question
    errors.add(:base, "Un modèle doit comporter au moins une question") if items.reject(&:marked_for_destruction?).empty?
  end

  def renumber_items
    return unless items.any?(&:changed_for_autosave?)

    items.reject(&:marked_for_destruction?).each_with_index { |item, index| item.position = index }
  end
end
