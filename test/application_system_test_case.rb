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

  DIALOG = "dialog.confirm[open]".freeze

  # Attend la boîte de confirmation ouverte et son animation d'entrée terminée : un clic pendant le rebond rate sa cible.
  def wait_for_confirm_dialog
    assert_selector DIALOG
    page.document.synchronize do
      settled = evaluate_script("document.querySelector('dialog.confirm').getAnimations().length") == 0
      raise Capybara::ElementNotFound, "la boîte de confirmation s'anime encore" unless settled
    end
  end

  # À appeler juste après le clic sur le déclencheur (remplace accept_confirm, qui ne voit que les alertes natives).
  def accept_confirm_dialog
    wait_for_confirm_dialog
    find("#{DIALOG} button[value=ok]").click
    assert_no_selector DIALOG
  end

  def dismiss_confirm_dialog
    wait_for_confirm_dialog
    find("#{DIALOG} button[value=cancel]").click
    assert_no_selector DIALOG
  end
end
