# Tasks

## 1. Données et modèle

- [x] 1.1 Migration ajoutant `respondents.last_invited_at` avec backfill `campaigns.updated_at` pour les campagnes `running` et `closed` ; vérifier avec `bin/rails db:migrate` puis `db:rollback`, et que `db/schema.rb` contient la colonne
- [x] 1.2 Ajouter `Respondent#invitable?` et `Respondent#invite!` (date + `deliver_later`) ; tests de modèle : éligible, déjà soumis, campagne brouillon/clôturée, date limite dépassée, date posée et email mis en file
- [x] 1.3 Faire utiliser `invite!` par `Campaign#launch!` ; mettre à jour le test de lancement pour vérifier que `last_invited_at` est renseigné pour chaque sondé

## 2. Route, contrôleur et interface

- [x] 2.1 Ajouter la route `POST /campaigns/:campaign_id/respondents/:id/resend` et `RespondentsController#resend` avec garde `invitable?`, redirect vers la campagne et flash (succès ou alerte) ; test d'intégration : renvoi nominal, sondé soumis, campagne clôturée ou date dépassée, campagne d'un autre manager (404)
- [x] 2.2 Mettre à jour `campaigns/show` : colonnes « Invité le … » et action « Renvoyer » (avec confirmation, seulement si `invitable?`) et ajouter les textes aux locales ; test d'intégration vérifiant la présence/absence du bouton et l'affichage de la date
- [x] 2.3 Vérification manuelle en développement : lancer une campagne, renvoyer à un sondé et contrôler l'email dans `/letter_opener` (même lien) et la date mise à jour dans le tableau ; lancer `bin/rails test` en entier

## Workflow follow-up

- Archiver le change une fois la revue terminée.
