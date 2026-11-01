module RespondentFormsHelper
  # Même phrase que celle du contrôleur Stimulus answer_progress, qui la reprend à chaque saisie.
  def remaining_fields_text(remaining)
    case remaining
    when 0 then "Tout est renseigné : vous pouvez soumettre."
    when 1 then "Il reste 1 champ à renseigner."
    else "Il reste #{remaining} champs à renseigner."
    end
  end
end
