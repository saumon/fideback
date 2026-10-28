# Design

## Context

`RespondentMailer.invitation(respondent)` existe déjà et n'a besoin que du sondé ; `Campaign#launch!` l'appelle en `deliver_later` pour chaque sondé. Le jeton de `Respondent` est fixé à la création, donc un renvoi réutilise le même lien. `Campaign#accepting_answers?` (en cours et date limite non dépassée) porte déjà la règle « le lien est encore utilisable ». La page `campaigns/show` liste les sondés dans un tableau sans colonne d'actions. Les campagnes sont toujours chargées via `current_manager.campaigns`.

## Goals / Non-Goals

**Goals:**
- Renvoi en un clic, sûr (campagne et sondé éligibles, isolation entre managers).
- Date de dernière invitation visible dans le tableau.

**Non-Goals:**
- Compteur ou historique d'envois, confirmation de livraison SMTP, limitation de fréquence.

## Decisions

- **Colonne unique `respondents.last_invited_at` (datetime, nullable)** plutôt qu'un compteur ou une table `invitations` : seul le dernier envoi est utile au manager, et un historique reste ajoutable plus tard.
- **Date posée à la mise en file**, dans la même transaction que le `deliver_later`, plutôt qu'à la livraison : simple, fiable, et le tableau est à jour immédiatement. La date signifie « demandé le… ». Un échec SMTP asynchrone relève de la supervision des jobs.
- **`Respondent#invite!`** : fait `update!(last_invited_at: Time.current)` puis `RespondentMailer.invitation(self).deliver_later`. `Campaign#launch!` l'utilise pour tous les sondés, ce qui évite deux chemins d'envoi.
- **`Respondent#invitable?`** : `campaign.accepting_answers? && !submitted?`. La vue (bouton) et le contrôleur (garde) s'appuient sur ce prédicat, pour une règle unique.
- **Route imbriquée `POST /campaigns/:campaign_id/respondents/:id/resend`** (`member` de `resources :respondents` dans `campaigns`), traitée par un `RespondentsController` minimal. Le sondé est cherché via `current_manager.campaigns.find(...).respondents.find(...)` : un identifiant étranger donne un 404, comme pour les campagnes. Un sondé non `invitable?` donne un redirect avec alerte, sans envoi.
- **Migration** : ajout de la colonne, puis backfill `last_invited_at = campaigns.updated_at` pour les sondés des campagnes `running` et `closed` (valeurs 1 et 2 de l'enum), via SQL pour ne pas dépendre des modèles. Date approximative mais préférable à « jamais invité » pour des sondés réellement invités.
- **Affichage** : colonne « Invité le … » (« — » si vide) et colonne d'action avec `button_to "Renvoyer"` et `turbo_confirm`, visible seulement si `respondent.invitable?`.

## Risks / Trade-offs

- [La date reflète la demande, pas la livraison] → documenté ; hors périmètre.
- [Backfill approximatif : `updated_at` bouge à la clôture] → acceptable, projet jeune ; les nouvelles dates sont exactes.
- [Clics répétés = emails répétés] → confirmation Turbo ; pas de limitation de fréquence pour l'instant.
