# Tasks

## 1. Notification

- [x] 1.1 Ajouter `ManagerNotifier.respondent_submitted(respondent)` : message Telegram seul, noms échappés, lien `campaign_url` ; vérifier avec des tests dans `test/services/manager_notifier_test.rb` (message envoyé si Telegram actif avec nom du sondé, nom de la campagne et lien ; rien si inactif ; échappement de « <b> » et « & »)
- [x] 1.2 Appeler cette notification dans `Respondent#submit!`, après l'enregistrement de `submitted_at` et avant `close_when_complete!` ; vérifier avec des tests dans `test/models/respondent_test.rb` (un message à la soumission, aucun si soumission refusée pour champs manquants ou campagne fermée, aucun à l'enregistrement sans soumettre, deux messages dans l'ordre pour le dernier sondé)
- [x] 1.3 Vérifier de bout en bout que soumettre depuis le formulaire sondé met un seul `TelegramMessageJob` en file pour le manager actif (test d'intégration ou de contrôleur existant dans `test/controllers`) et aucun pour un manager inactif

## 2. Documentation et contrôle

- [x] 2.1 Mentionner la nouvelle notification dans la section Telegram du `README.md` et vérifier qu'elle correspond au comportement
- [x] 2.2 Lancer la suite de tests complète et `openspec validate notify-manager-on-respondent-submission --strict`, et vérifier qu'elles passent
