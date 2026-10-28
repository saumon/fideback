class Manager < ApplicationRecord
  # :confirmable — le compte reste inactif jusqu'au clic sur le lien reçu par
  #                e-mail ; sert aussi à valider une adresse modifiée
  #                (config.reconfirmable).
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable

  has_many :campaigns, dependent: :destroy

  validates :name, presence: true

  # Envoie un nouvel e-mail d'activation dont le lien remplace les précédents.
  # Jamais resend_confirmation_instructions seul : il renvoie le même jeton tant
  # qu'il n'a pas expiré, et chaque e-mail déjà envoyé continuerait de marcher.
  # Vider le jeton force Devise à en générer un nouveau.
  def resend_activation!
    self.confirmation_token = nil
    @raw_confirmation_token = nil
    resend_confirmation_instructions
  end
end
