class Manager < ApplicationRecord
  # :confirmable — le compte reste inactif jusqu'au clic sur le lien reçu par
  #                e-mail ; sert aussi à valider une adresse modifiée
  #                (config.reconfirmable).
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  enum :role, { manager: "manager", admin: "admin" }, default: :manager

  # Le tout premier compte créé administre le site. Dans la transaction de
  # l'insertion, pour que deux inscriptions simultanées ne l'obtiennent pas
  # toutes les deux ; personne ne le reprend si ce compte disparaît.
  before_create { self.role = :admin if Manager.none? }

  has_many :campaigns, dependent: :destroy
  has_many :contacts, -> { order(:name, :id) }, dependent: :destroy, inverse_of: :manager

  accepts_nested_attributes_for :contacts, allow_destroy: true,
                                reject_if: ->(attrs) { attrs.values_at("name", "email").all?(&:blank?) }

  validates :name, presence: true
  validate :contact_emails_unique_within_submission

  # Envoie un nouvel e-mail d'activation dont le lien remplace les précédents.
  # Jamais resend_confirmation_instructions seul : il renvoie le même jeton tant
  # qu'il n'a pas expiré, et chaque e-mail déjà envoyé continuerait de marcher.
  # Vider le jeton force Devise à en générer un nouveau.
  def resend_activation!
    self.confirmation_token = nil
    @raw_confirmation_token = nil
    resend_confirmation_instructions
  end

  private

  # La validation d'unicité de Contact ne lit que la base : deux lignes neuves
  # du même envoi portant le même e-mail passeraient toutes les deux.
  def contact_emails_unique_within_submission
    contacts.target.reject(&:marked_for_destruction?).group_by(&:email).each do |email, same|
      next if email.blank? || same.size < 2

      same.drop(1).each { |contact| contact.errors.add(:email, :taken) }
      errors.add(:base, "L'e-mail #{email} figure plusieurs fois dans l'annuaire")
    end
  end
end
