module CampaignsHelper
  # Détail de la boîte de confirmation d'une suppression : pour une campagne clôturée, ce qui sera perdu, chiffré.
  def delete_campaign_detail(campaign, submitted, total)
    return "Les réponses des sondés et la synthèse seront perdues. Cette action est définitive." if campaign.draft?
    return "Aucun sondé n'a répondu. Cette action est définitive." if submitted.zero?

    lead = submitted == 1 ? "La réponse de 1 sondé sur #{total}" : "Les réponses de #{submitted} sondés sur #{total}"
    "#{lead} et la synthèse seront perdues. Cette action est définitive."
  end
end
