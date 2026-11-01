# Tasks

## 1. Règle côté serveur

- [x] 1.1 Remplacer `Respondent#missing_ratings` par `missing_answers` (triplets managé, question, `:rating` ou `:body`, dans l'ordre de la page, une seule requête) et faire refuser `submit!` tant qu'il en reste, puis adapter `answer_fully` de `test_helper.rb` pour renseigner aussi les commentaires, et vérifier par des tests de modèle : note manquante, commentaire manquant, question à commentaire seul, commentaire d'espaces, commentaire d'un caractère accepté, soumission complète acceptée, ordre des triplets
- [x] 1.2 Faire annoncer par `RespondentFormsController#submit` le nombre de champs manquants (« Il manque N champs : … », singulier compris) et vérifier par des tests d'intégration : refus 422 avec le bon nombre, saisie conservée, soumission refusée sans commentaire et acceptée avec « ok », enregistrement partiel toujours permis, sondé ayant déjà soumis non concerné

## 2. Formulaire du sondé

- [x] 2.1 Dans `respondent_forms/show`, afficher la mention « obligatoire pour soumettre » à côté de chaque note et commentaire, un signalement par champ manquant (`Note manquante`, `Commentaire manquant`), l'`autofocus` sur le premier champ manquant et l'état de départ du compteur rendu par le serveur dans la barre d'actions, avec le style correspondant et un `scroll-padding-bottom`, et vérifier par des tests d'intégration sur ces éléments, y compris sur une page déjà soumise (aucune mention)
- [x] 2.2 Créer le contrôleur Stimulus `answer_progress` (recompte à chaque `input`, valeur vide après suppression des espaces, message « Il reste N champs » ou « Tout est renseigné », défilement jusqu'au champ en `autofocus` après un refus) et faire émettre un événement `input` par `rating#pick`, puis vérifier par un test système : compteur initial, diminution à la saisie d'une note par bouton et d'un commentaire, hausse quand on efface

## 3. Parcours

- [x] 3.1 Créer un test système du sondé : soumission refusée avec les champs signalés et le focus sur le premier, visible et au-dessus de la barre d'actions dans une fenêtre courte, compteur du chargement et après refus égal au nombre de champs signalés, saisie conservée, « ok » accepté, enregistrement partiel permis ; vérifier que `bin/rails test:system` passe en entier
- [x] 3.2 Vérifier que le parcours complet `feedback_journey_test` et le test de clôture automatique passent avec la nouvelle règle, et corriger leurs données si elles omettent des commentaires

## 4. Documentation et vérifications

- [x] 4.1 Mettre à jour `docs/fonctionnement.md` (la soumission exige notes et commentaires, mention, compteur, signalement, campagnes existantes) en remplaçant les passages qui ne parlent que de notes, et vérifier qu'aucune phrase ne contredit la nouvelle règle
- [x] 4.2 Vérifier avec `openspec validate require-comments-to-submit --strict`, puis `bin/rails test`, `bin/rubocop`, `bin/rails test:system` et `bin/ci` au vert

## Workflow follow-up

- Archiver le changement avec `/opsx:archive` (synchronisation vers `feedback-submission`, une exigence modifiée et deux ajoutées), puis terminer avec `/saumon-finish`.
