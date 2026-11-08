# La section « Notifications Telegram » de la page du compte. Hors de Devise : elle s'enregistre sans le mot de
# passe actuel et ne touche ni au nom, ni à l'e-mail, ni au mot de passe.
class TelegramSettingsController < ApplicationController
  def update
    manager = current_manager
    if manager.update(settings_params)
      redirect_to edit_manager_registration_path, notice: saved_notice(manager), status: :see_other
    else
      saved = Manager.find(manager.id)
      render turbo_stream: turbo_stream.replace("telegram-settings", partial: "telegram_settings/section",
                                                                  locals: { manager: manager, saved: saved }),
             status: :unprocessable_entity
    end
  end

  # Avec le token saisi s'il y en a un, même pas encore enregistré, sinon avec le token enregistré. N'enregistre rien.
  def detect
    token = params.dig(:manager, :telegram_bot_token).to_s.strip.presence || current_manager.readable_telegram_bot_token
    result = Telegram::ChatDetection.call(token)
    chat_id = result.found? ? result.chat_id : params.dig(:manager, :telegram_chat_id)

    render turbo_stream: turbo_stream.replace("telegram-chat", partial: "telegram_settings/chat_field",
                                                               locals: { chat_id: chat_id, detection: result })
  end

  # Envoyé tout de suite, pour montrer le résultat, que les notifications soient activées ou non.
  def test_message
    manager = current_manager
    unless manager.telegram_configured?
      return redirect_to edit_manager_registration_path, status: :see_other,
                         alert: "Enregistrez d'abord le token du bot et l'identifiant de conversation."
    end

    Telegram::BotClient.new(manager.readable_telegram_bot_token).send_message(manager.telegram_chat_id, test_text)
    redirect_to edit_manager_registration_path, notice: "Message de test envoyé : regardez dans Telegram.", status: :see_other
  rescue Telegram::BotClient::Error => error
    redirect_to edit_manager_registration_path, alert: Telegram::ChatDetection.error_message(error), status: :see_other
  end

  private

  # Un champ de token laissé vide garde le token enregistré : il n'est jamais réaffiché, le manager ne le ressaisit pas.
  def settings_params
    permitted = params.expect(manager: %i[telegram_bot_token telegram_chat_id telegram_enabled])
    permitted.delete(:telegram_bot_token) if permitted[:telegram_bot_token].blank?
    permitted
  end

  def saved_notice(manager)
    manager.telegram_enabled? ? "Notifications Telegram activées." : "Réglages Telegram enregistrés, notifications désactivées."
  end

  def test_text
    "👋 <b>Fideback est bien relié à ce bot.</b>\n\nVos notifications arriveront ici, en plus des e-mails."
  end
end
