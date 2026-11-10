# Proposal

## Why

Un manager ne sait qu'un sondé a répondu qu'en ouvrant la page de sa campagne, ou à la clôture quand tous ont répondu. Telegram sait déjà le prévenir de la clôture : il doit aussi le prévenir de chaque réponse, au moment où elle arrive.

## What Changes

- Quand un sondé soumet définitivement ses réponses, le manager de la campagne reçoit un message Telegram qui nomme le sondé et la campagne et renvoie vers la page de la campagne.
- Le message ne part que si les notifications Telegram du manager sont activées.
- Cette notification n'a pas d'e-mail jumeau : l'exigence « Telegram en plus de l'e-mail » est ajustée en conséquence.
- Quand la soumission est la dernière, le manager reçoit les deux messages : « X a répondu », puis « campagne clôturée ».

## Capabilities

### New Capabilities

### Modified Capabilities
- `telegram-notifications`: ajout d'une notification de réponse d'un sondé, envoyée sur Telegram seulement ; la règle « en plus de l'e-mail » ne vaut plus pour cette notification.

## Impact

- `app/services/manager_notifier.rb` : nouvelle notification du manager.
- `app/models/respondent.rb` : `submit!` déclenche la notification.
- Tests de `ManagerNotifier` et de `Respondent#submit!`.
- Aucune migration, aucune route, aucune vue, aucune dépendance.
