# Design

## Context

`ManagerNotifier` est le point d'entrée des notifications du manager. `campaign_completed` y envoie l'e-mail puis appelle `telegram(manager, texte)`, qui ne met le job en file que si `manager.telegram_active?`. `TelegramMessageJob` relit la configuration à l'envoi, retente les erreurs temporaires et journalise les échecs définitifs. Le texte part en HTML Telegram, donc les noms sont échappés. Voir proposal.md pour la motivation.

`Respondent#submit!` enregistre `submitted_at` puis appelle `campaign.close_when_complete!`, qui notifie la clôture.

## Goals / Non-Goals

**Goals:**
- Réutiliser le chemin d'envoi existant : condition d'activation, échappement, relances, échecs silencieux.

**Non-Goals:**
- Aucune page « réponses d'un sondé » : le lien pointe vers la page de la campagne, qui montre déjà qui a répondu.
- Aucun e-mail pour cette notification.
- Aucun réglage fin (par exemple « seulement la clôture ») : l'interrupteur Telegram existant reste le seul.

## Decisions

- **Nouvelle méthode `ManagerNotifier.respondent_submitted(respondent)`** qui n'appelle que `telegram`, sans e-mail. Alternative écartée : un second job ou un callback de modèle, qui dupliquerait la condition d'activation.
- **Déclenchement dans `Respondent#submit!`**, après `update!(submitted_at:)` et avant `campaign.close_when_complete!`. Cela garantit l'ordre « X a répondu » puis « clôturée » pour le dernier sondé (les jobs partent dans l'ordre de mise en file) et ne notifie ni une soumission refusée, ni un simple enregistrement. Alternative écartée : le contrôleur, car la notification suivrait alors le chemin HTTP au lieu de la règle métier.
- **Lien vers `campaign_url`**, construit avec `url_options` comme le message de clôture.
- **Message** : titre court avec le nom du sondé, puis une ligne « <sondé> a soumis ses réponses à la campagne « <campagne> » », puis le lien « Voir la campagne ». Noms échappés avec `escape`.
- **Mise en file seulement** : `perform_later` ne fait pas échouer `submit!` si Telegram est en panne, et la confirmation du sondé n'est pas affectée.

## Risks / Trade-offs

- [Beaucoup de sondés, beaucoup de messages] → Assumé : le manager peut désactiver l'interrupteur Telegram. Aucun regroupement prévu.
- [Deux messages d'affilée pour le dernier sondé] → Voulu, confirmé avec le demandeur.
- [Ordre des messages non garanti si les jobs sont exécutés en parallèle] → Les deux jobs partent presque ensemble ; un échange d'ordre éventuel est sans conséquence, et le spec ne promet que l'ordre de mise en file.
