require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Lu par les fichiers d'environnement, l'initialiseur Devise et ApplicationMailer.
require_relative "mailer_settings"

module Fideback
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [ :fr ]
    config.time_zone = "Paris"

    # Clés du chiffrement Active Record (token des bots Telegram des managers). Rails les lit déjà dans
    # credentials.active_record_encryption ; une variable ACTIVE_RECORD_ENCRYPTION_* non vide passe devant,
    # sur le modèle des réglages mail.
    {
      primary_key: "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY",
      deterministic_key: "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY",
      key_derivation_salt: "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT"
    }.each do |key, env|
      config.active_record.encryption[key] = ENV[env] if ENV[env].present?
    end
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
