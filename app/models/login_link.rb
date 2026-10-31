# Lien à usage unique qui ouvre la session d'un manager quand l'Admin exige la connexion par lien. Le jeton est
# stocké tel quel, comme celui des invitations : l'e-mail est mis en file avec le lien en argument, donc le jeton
# traverse la base de la file de toute façon ; il est protégé par sa brièveté, son usage unique et sa longueur.
class LoginLink < ApplicationRecord
  VALIDITY = 10.minutes
  COOLDOWN = 1.minute

  belongs_to :manager

  has_secure_token :token, length: 36

  # Envoie un lien au manager, en invalidant les précédents. Retourne nil, sans rien envoyer, si un lien lui a été
  # envoyé il y a moins d'une minute : le lien déjà reçu reste valable.
  def self.issue_for(manager)
    transaction do
      manager.login_links.where(expires_at: ...Time.current).delete_all
      next if cooling_down?(manager)

      manager.login_links.delete_all
      link = manager.login_links.create!(expires_at: VALIDITY.from_now)
      LoginLinkMailer.link(link).deliver_later
      link
    end
  end

  # Secondes à attendre avant qu'un nouveau lien puisse être envoyé, 0 si c'est possible tout de suite.
  def self.cooldown_remaining(manager)
    last = manager.login_links.maximum(:created_at)
    return 0 unless last

    [ (last + COOLDOWN - Time.current).ceil, 0 ].max
  end

  def self.cooling_down?(manager)
    cooldown_remaining(manager).positive?
  end

  def usable?
    used_at.nil? && expires_at.future?
  end

  # Marque le lien utilisé, une seule fois même si deux clics arrivent ensemble. Retourne false s'il ne l'est plus.
  def consume!
    self.class.where(id: id, used_at: nil).where(expires_at: Time.current..).update_all(used_at: Time.current).positive?
  end
end
