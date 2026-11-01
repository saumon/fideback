class CampaignMailer < ApplicationMailer
  # Prévient le manager que sa campagne s'est clôturée parce que tous les sondés ont soumis leurs réponses.
  def completed(campaign)
    @campaign = campaign
    @manager = campaign.manager
    count = campaign.respondents.count
    @intro = if count == 1
      "La réponse de votre sondé est soumise : la campagne « #{campaign.name} » est clôturée et sa synthèse est complète."
    else
      "Les réponses de #{count} sondés sont toutes soumises : la campagne « #{campaign.name} » est clôturée et sa synthèse est complète."
    end
    @url = campaign_url(campaign)

    mail to: email_address_with_name(@manager.email, @manager.name), subject: "Tous vos sondés ont répondu : campagne clôturée"
  end
end
