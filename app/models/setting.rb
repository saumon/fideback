# Réglages globaux du site, une ligne par clé. Une clé absente vaut sa valeur par défaut :
# la table peut rester vide, et un nouveau réglage n'exige ni migration ni ligne de départ.
class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true

  # Les inscriptions de nouveaux managers sont ouvertes tant que l'Admin ne les a pas fermées.
  def self.registrations_open?
    find_by(key: "registrations_open")&.value != "false"
  end

  def self.registrations_open=(open)
    setting = find_or_initialize_by(key: "registrations_open")
    setting.update!(value: open ? "true" : "false")
  end

  # La connexion par lien unique est désactivée tant que l'Admin ne l'a pas activée.
  def self.login_link_required?
    find_by(key: "login_link_required")&.value == "true"
  end

  def self.login_link_required=(required)
    setting = find_or_initialize_by(key: "login_link_required")
    setting.update!(value: required ? "true" : "false")
  end
end
