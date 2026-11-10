# Point d'entrée unique des notifications destinées au manager : l'e-mail part toujours, le message Telegram en plus
# quand le manager l'a activé. Les e-mails d'authentification (lien de connexion, activation, réinitialisation) et ceux
# adressés aux sondés ou aux invités n'en font pas partie : ils ne passent jamais par Telegram.
module ManagerNotifier
  module_function

  # Tous les sondés ont soumis : la campagne vient de se clôturer d'elle-même.
  def campaign_completed(campaign)
    CampaignMailer.completed(campaign).deliver_later

    count = campaign.respondents.count
    answered = count == 1 ? "Votre sondé a répondu" : "Vos #{count} sondés ont tous répondu"
    telegram(campaign.manager, <<~TEXT.strip)
      ✅ <b>Tous vos sondés ont répondu : campagne clôturée</b>

      #{answered} : la campagne « #{escape(campaign.name)} » est clôturée et sa synthèse est complète.

      <a href="#{escape(url_helpers.campaign_url(campaign, **url_options))}">Voir la synthèse</a>
    TEXT
  end

  # Un sondé vient de soumettre ses réponses. Pas d'e-mail : le manager le sait par Telegram seulement, et voit le
  # détail sur la page de la campagne.
  def respondent_submitted(respondent)
    campaign = respondent.campaign
    telegram(campaign.manager, <<~TEXT.strip)
      📝 <b>#{escape(respondent.name)} a répondu</b>

      #{escape(respondent.name)} a soumis ses réponses à la campagne « #{escape(campaign.name)} ».

      <a href="#{escape(url_helpers.campaign_url(campaign, **url_options))}">Voir la campagne</a>
    TEXT
  end

  def telegram(manager, text)
    TelegramMessageJob.perform_later(manager, text) if manager.telegram_active?
  end

  # Le texte part en HTML Telegram : un nom de campagne qui contient « <b> » ou « & » doit s'afficher tel quel.
  def escape(text)
    ERB::Util.html_escape(text)
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  # Les liens pointent vers l'adresse publique, comme ceux des e-mails.
  def url_options
    ActionMailer::Base.default_url_options
  end
end
