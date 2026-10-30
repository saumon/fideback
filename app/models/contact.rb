# Personne de l'annuaire d'un manager, réutilisée d'une campagne à l'autre
# comme managé (managed) et/ou sondé (surveyable).
class Contact < ApplicationRecord
  belongs_to :manager
  has_many :subjects, dependent: nil # copies figées des campagnes lancées : la FK les détache
  has_many :respondents, dependent: nil

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :email, presence: true
  validates :email, uniqueness: { scope: :manager_id, case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validate :has_a_role

  scope :managed, -> { where(managed: true) }
  scope :surveyable, -> { where(surveyable: true) }

  # Les brouillons suivent l'annuaire ; les campagnes lancées gardent leur copie.
  after_update :sync_draft_copies
  before_destroy :remove_from_drafts

  private

  def draft(copies)
    copies.joins(:campaign).where(campaigns: { status: Campaign.statuses[:draft] })
  end

  def sync_draft_copies
    if saved_change_to_name? || saved_change_to_email?
      [ subjects, respondents ].each { |copies| draft(copies).update_all(name: name, email: email, updated_at: Time.current) }
    end
    draft(subjects).destroy_all unless managed?
    draft(respondents).destroy_all unless surveyable?
  end

  def remove_from_drafts
    draft(subjects).destroy_all
    draft(respondents).destroy_all
  end

  def has_a_role
    errors.add(:base, "#{name.presence || email} doit être managé, sondable ou les deux") unless managed? || surveyable?
  end
end
