require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  SCREEN_SIZE = [ 1400, 1400 ].freeze

  driven_by :selenium, using: :headless_chrome, screen_size: SCREEN_SIZE do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    # Les mots de passe des fixtures (« password123 ») figurent dans les bases de fuites. Sans ce réglage, Chrome
    # affiche son alerte de mot de passe compromis après l'envoi d'un formulaire de connexion, selon l'adresse
    # saisie, et les clics suivants n'atteignent plus la page.
    options.add_preference("profile.password_manager_leak_detection", false)
  end
end
