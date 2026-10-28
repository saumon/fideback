# Où part le courrier sortant, de quelle adresse, et vers quelle adresse
# pointent ses liens : réglable par déploiement sans toucher à l'application.
#
# Chaque valeur se résout ENV → credentials chiffrés → défaut. Une valeur ENV
# vide compte comme absente, pour qu'une variable laissée vide dans un fichier
# de déploiement n'écrase pas un vrai credential par du vide.
#
# Chargé par config/application.rb avant la classe d'application, car les
# fichiers d'environnement, l'initialiseur Devise et ApplicationMailer le lisent.
module Fideback
  module MailerSettings
    DEFAULT_SENDER = "Fideback <fideback@example.com>".freeze

    module_function

    def smtp_settings
      {
        address: setting(:smtp, :address, env: "SMTP_ADDRESS"),
        port: integer_setting(:smtp, :port, env: "SMTP_PORT"),
        domain: setting(:smtp, :domain, env: "SMTP_DOMAIN"),
        user_name: setting(:smtp, :user_name, env: "SMTP_USERNAME"),
        password: setting(:smtp, :password, env: "SMTP_PASSWORD"),
        authentication: symbol_setting(:smtp, :authentication, env: "SMTP_AUTHENTICATION", default: :plain),
        enable_starttls_auto: boolean_setting(:smtp, :enable_starttls_auto, env: "SMTP_ENABLE_STARTTLS_AUTO", default: true),
        openssl_verify_mode: setting(:smtp, :openssl_verify_mode, env: "SMTP_OPENSSL_VERIFY_MODE")
      }.compact
    end

    # SMTP n'est activé que s'il est autorisé et que ces quatre réglages sont
    # tous là : une configuration à moitié remplie vaut absence de configuration,
    # plutôt qu'un serveur qui refusera chaque message.
    def smtp_configured?
      return false unless smtp_enabled?

      settings = smtp_settings
      %i[address port user_name password].all? { |key| settings[key].present? }
    end

    # SMTP_ENABLED / smtp.enabled : un interrupteur explicite, pour garder une
    # configuration complète (dans les credentials, par exemple) sans rien
    # envoyer ; le développement retombe alors sur la boîte letter_opener.
    def smtp_enabled?
      boolean_setting(:smtp, :enabled, env: "SMTP_ENABLED", default: true)
    end

    # Le port par défaut appartient à l'hôte par défaut : localhost:3000 en
    # développement. Dès qu'APP_HOST désigne une autre adresse, garder :3000
    # casserait tous les liens ; seul APP_PORT fixe alors le port, et sans lui
    # les liens utilisent le port standard du protocole.
    def default_url_options(default_host:, default_port: nil, default_protocol: nil)
      host = setting(:app, :host, env: "APP_HOST")

      {
        host: host || default_host,
        port: integer_setting(:app, :port, env: "APP_PORT", default: (default_port if host.nil?)),
        protocol: setting(:app, :protocol, env: "APP_PROTOCOL", default: default_protocol)
      }.compact
    end

    # Un seul expéditeur pour Devise et pour ApplicationMailer.
    def mailer_sender
      setting(:smtp, :sender, env: "SMTP_SENDER") ||
        setting(:mailer, :sender, env: "MAILER_SENDER") ||
        DEFAULT_SENDER
    end

    def setting(namespace, key, env:, default: nil)
      ENV[env].presence || credential(namespace, key).presence || default
    end

    def integer_setting(namespace, key, env:, default: nil)
      value = setting(namespace, key, env: env, default: default)
      value.present? ? value.to_i : nil
    end

    # Pas construit sur #setting : son .presence transformerait un `false` des
    # credentials en « non défini » et retomberait sur le défaut, si bien que
    # `enabled: false` ne pourrait jamais rien désactiver.
    def boolean_setting(namespace, key, env:, default: nil)
      value = ENV[env].presence
      value = credential(namespace, key) if value.nil?
      return default if value.nil? || value == ""
      return value if value == true || value == false

      ActiveModel::Type::Boolean.new.cast(value)
    end

    def symbol_setting(namespace, key, env:, default: nil)
      value = setting(namespace, key, env: env, default: default)
      value.present? ? value.to_sym : nil
    end

    # Les credentials peuvent être absents (pas de clé maître dans un checkout
    # neuf, CI sans secrets) ou illisibles (clé qui ne correspond pas au
    # fichier). Dans les deux cas c'est « pas de valeur », pas une erreur : lire
    # les réglages mail ne doit pas empêcher `bin/rails credentials:edit` de
    # charger cet environnement et d'expliquer lui-même le problème de clé.
    def credential(namespace, key)
      Rails.application.credentials.dig(namespace, key)
    rescue ActiveSupport::EncryptedFile::MissingKeyError
      nil
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      warn_undecryptable_credentials
      nil
    end

    # Une fois par processus, sur stderr : cela s'exécute pendant la
    # configuration de l'environnement, avant que Rails.logger n'existe.
    def warn_undecryptable_credentials
      return if @undecryptable_credentials_warned

      @undecryptable_credentials_warned = true
      Kernel.warn("[mail] les credentials n'ont pas pu être déchiffrés (mauvaise clé maître ?) ; " \
                  "les réglages mail sont lus dans l'environnement uniquement")
    end
  end
end
