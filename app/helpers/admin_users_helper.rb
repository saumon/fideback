module AdminUsersHelper
  # Détail de la boîte de confirmation d'une suppression de manager : ce qui sera perdu, chiffré.
  def delete_manager_detail(campaigns_count)
    lost = case campaigns_count
    when 0 then "Il n'a aucune campagne."
    when 1 then "Sa campagne et toutes les réponses recueillies seront effacées."
    else "Ses #{campaigns_count} campagnes et toutes les réponses recueillies seront effacées."
    end
    "#{lost} Cette action est définitive."
  end
end
