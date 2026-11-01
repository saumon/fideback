# Tasks

## 1. Clôture automatique

- [x] 1.1 Ajouter à `Campaign` `all_submitted?` (évalué en base) et `close_when_complete!` (mise à jour conditionnelle `running` vers `closed`, vrai uniquement si elle a eu lieu), et vérifier par des tests de modèle : tous soumis, il en reste un, réponses seulement enregistrées, un seul sondé, campagne déjà clôturée, deux appels de suite qui ne clôturent qu'une fois
- [x] 1.2 Appeler `close_when_complete!` à la fin de `Respondent#submit!` et vérifier par des tests de modèle que la dernière soumission clôture la campagne, que la précédente la laisse en cours, et qu'une soumission refusée (date limite dépassée, notes manquantes) ne la clôture pas

## 2. E-mail au manager

- [x] 2.1 Créer `CampaignMailer#completed` avec ses vues HTML et texte (salutation par le nom, nom de la campagne, nombre de sondés, bouton vers la campagne) et vérifier par un test de mailer : destinataire, objet, salutation et lien dans les deux versions, expéditeur commun
- [x] 2.2 Mettre l'e-mail en file quand `close_when_complete!` réussit, et vérifier par un test d'intégration qu'il part une fois à la soumission du dernier sondé, jamais à la soumission d'un autre, ni à une clôture manuelle

## 3. Affichage

- [x] 3.1 Afficher dans `campaigns/show` la ligne d'état « Clôturée : tous les sondés ont répondu » quand la campagne est clôturée et que tous ont soumis, et vérifier par des tests d'intégration : présente après une clôture automatique, absente après une clôture manuelle avec un sondé manquant, absente en cours
- [x] 3.2 Vérifier par un test d'intégration que le dernier sondé voit « Merci ! Vos réponses ont été soumises » puis « Vous avez soumis vos réponses » sans le message de campagne terminée, et que sa soumission renvoie bien vers sa page

## 4. Parcours et documentation

- [x] 4.1 Étendre `feedback_journey_test` : après la soumission des deux sondés, le manager voit la campagne clôturée avec la ligne d'état, et l'e-mail de clôture est en file ; vérifier que `bin/rails test:system` passe en entier
- [x] 4.2 Documenter la clôture automatique dans `docs/fonctionnement.md` (un paragraphe : déclencheur, e-mail, ligne d'état, campagnes existantes non rattrapées) et la mentionner en une ligne dans *Fonctionnalités* du README
- [x] 4.3 Vérifier avec `openspec validate add-auto-close-campaign --strict`, puis `bin/rails test`, `bin/rubocop`, `bin/rails test:system` et `bin/ci` au vert

## Workflow follow-up

- Archiver le changement avec `/opsx:archive` (synchronisation vers `feedback-campaigns` et `feedback-submission`), puis terminer avec `/saumon-finish`.
