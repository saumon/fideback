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
  has_many :login_links, dependent: :delete_all
  has_many :contacts, -> { order(:name, :id) }, dependent: :destroy, inverse_of: :manager

  accepts_nested_attributes_for :contacts, allow_destroy: true,
                                reject_if: ->(attrs) { attrs.values_at("name", "email").all?(&:blank?) }

  # Notifications Telegram : le bot que le manager a créé avec BotFather écrit dans sa conversation privée.
  # Le token donne le contrôle complet du bot : il est chiffré et ne se réaffiche jamais.
  TELEGRAM_TOKEN_FORMAT = /\A\d+:[A-Za-z0-9_-]{30,}\z/
  TELEGRAM_CHAT_ID_FORMAT = /\A-?\d+\z/

  encrypts :telegram_bot_token
  normalizes :telegram_bot_token, :telegram_chat_id, with: ->(value) { value.strip.presence }

  validates :name, presence: true
  validate :contact_emails_unique_within_submission
  # Seulement quand le token change : relire un token que les clés actuelles ne déchiffrent plus ferait échouer
  # tout enregistrement du manager, connexion comprise.
  validates :telegram_bot_token, format: { with: TELEGRAM_TOKEN_FORMAT, message: "n'a pas le format d'un token de bot Telegram" },
                                 allow_nil: true, if: :telegram_bot_token_changed?
  validates :telegram_chat_id, format: { with: TELEGRAM_CHAT_ID_FORMAT, message: "doit être numérique" }, allow_nil: true
  validate :telegram_activation_needs_configuration

  # Les deux voies de Devise qui ouvrent une session sans repasser par le lien de connexion sont coupées tant que
  # l'Admin exige la connexion par lien unique : le cookie « se souvenir de moi » et la connexion qui suit une
  # réinitialisation du mot de passe.
  def self.serialize_from_cookie(*)
    super unless Setting.login_link_required?
  end

  def self.sign_in_after_reset_password
    super && !Setting.login_link_required?
  end

  # Envoie un nouvel e-mail d'activation dont le lien remplace les précédents.
  # Jamais resend_confirmation_instructions seul : il renvoie le même jeton tant
  # qu'il n'a pas expiré, et chaque e-mail déjà envoyé continuerait de marcher.
  # Vider le jeton force Devise à en générer un nouveau.
  def resend_activation!
    self.confirmation_token = nil
    @raw_confirmation_token = nil
    resend_confirmation_instructions
  end

  # Le token enregistré, ou nil s'il manque ou si les clés de chiffrement actuelles ne le déchiffrent plus : le
  # manager n'a alors qu'à le ressaisir.
  def readable_telegram_bot_token
    telegram_bot_token
  rescue ActiveRecord::Encryption::Errors::Decryption
    Rails.logger.warn("[telegram] token du manager #{id} indéchiffrable, considéré comme absent")
    nil
  end

  def telegram_configured?
    telegram_chat_id.present? && readable_telegram_bot_token.present?
  end

  def telegram_active?
    telegram_enabled? && telegram_configured?
  end

  # Ce que la page du compte montre d'un token enregistré : ses quatre derniers caractères.
  def masked_telegram_bot_token
    token = readable_telegram_bot_token
    "••••#{token.last(4)}" if token
  end

  private

  def telegram_activation_needs_configuration
    return unless telegram_enabled?
    return unless will_save_change_to_telegram_enabled? || telegram_bot_token_changed? || will_save_change_to_telegram_chat_id?
    return if telegram_configured?

    errors.add(:telegram_enabled, :incomplete, message: "demande un token et un identifiant de conversation")
  end

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
