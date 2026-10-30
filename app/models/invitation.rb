# Invitation d'une personne à devenir manager. Elle existe à part du compte : le manager n'est créé qu'à
# l'acceptation, déjà activé puisque le clic sur le lien reçu par e-mail prouve la boîte mail.
# Une invitation acceptée reste en base, avec sa date, pour l'historique.
class Invitation < ApplicationRecord
  VALIDITY = 7.days

  belongs_to :invited_by, class_name: "Manager", optional: true

  has_secure_token :token, length: 36

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validate :email_not_registered, unless: :accepted?

  scope :unaccepted, -> { where(accepted_at: nil) }

  # Invite une adresse. Si une invitation non acceptée existe déjà pour elle, elle est remplacée : même ligne,
  # nouveau jeton, ancien lien invalide. L'invitation retournée porte ses erreurs si elle est refusée.
  def self.invite(name:, email:, by:)
    attempts = 0
    begin
      invitation = unaccepted.find_or_initialize_by(email: email.to_s)
      invitation.name = name
      invitation.renew(by: by)
      invitation
    rescue ActiveRecord::RecordNotUnique
      # Deux invitations simultanées à la même adresse : la seconde retrouve la première et la remplace.
      attempts += 1
      retry if attempts < 2
      raise
    end
  end

  # Nouveau lien, validité repartie de zéro, nouvel e-mail. Sert au renvoi comme au remplacement.
  # Retourne false, avec les erreurs de l'invitation, si elle ne peut plus être envoyée.
  def renew(by:)
    self.token = self.class.generate_unique_secure_token(length: 36)
    self.expires_at = VALIDITY.from_now
    self.invited_by = by
    return false unless save

    InvitationMailer.invitation(self).deliver_later
    true
  end

  def accepted?
    accepted_at.present?
  end

  def expired?
    !accepted? && expires_at <= Time.current
  end

  def pending?
    !accepted? && expires_at > Time.current
  end

  # Le lien peut encore servir : en attente, et l'adresse n'a pas obtenu de compte entre-temps.
  def acceptable?
    pending? && !Manager.exists?(email: email)
  end

  # Crée le compte, activé d'emblée et sans e-mail d'activation, puis consomme l'invitation. Retourne le manager,
  # qui porte ses erreurs s'il n'a pas pu être créé.
  def accept(name:, password:, password_confirmation:)
    manager = Manager.new(name: name, email: email, password: password, password_confirmation: password_confirmation)
    manager.skip_confirmation!
    transaction do
      update!(accepted_at: Time.current) if manager.save
    end
    manager
  end

  private

  def email_not_registered
    errors.add(:email, :taken) if email.present? && Manager.exists?(email: email)
  end
end
