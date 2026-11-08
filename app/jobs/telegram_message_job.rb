# Envoie une notification au manager par son bot Telegram. Un échec n'est jamais signalé au manager : une erreur
# temporaire est retentée, une erreur définitive (bot bloqué, token révoqué, conversation inconnue) est écrite dans le
# journal, sans toucher à la configuration.
class TelegramMessageJob < ApplicationJob
  queue_as :default

  MAX_ATTEMPTS = 5

  # Manager supprimé entre la mise en file et l'envoi : plus personne à prévenir.
  discard_on ActiveJob::DeserializationError

  rescue_from Telegram::BotClient::Error do |error|
    if error.temporary? && executions < MAX_ATTEMPTS
      # retry_on ne sait pas attendre le délai que Telegram demande sur un 429 : on relance à la main.
      retry_job(wait: error.retry_after&.seconds || (executions**4 + 2).seconds)
    else
      Rails.logger.warn("[telegram] notification au manager #{arguments.first&.id} abandonnée : #{error.message}")
    end
  end

  # Telegram peut avoir été désactivé entre la mise en file et l'envoi : on relit la configuration.
  def perform(manager, text)
    return unless manager.telegram_active?

    Telegram::BotClient.new(manager.readable_telegram_bot_token).send_message(manager.telegram_chat_id, text)
  end
end
