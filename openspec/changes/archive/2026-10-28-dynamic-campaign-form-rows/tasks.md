# Tasks

## 1. Position des questions côté serveur

- [x] 1.1 Ajouter dans `Campaign` un `before_validation` qui réaffecte `position` aux questions non marquées pour suppression, dans l'ordre de soumission. Vérification : test de modèle où l'ajout et la suppression de questions donnent des positions 0..n-1 sans doublon.

## 2. Partials du formulaire

- [x] 2.1 Extraire un partial `_question_fields.html.erb` (énoncé, note, commentaire, bouton « Supprimer », sans champ `position`). Vérification : le formulaire de création affiche toujours les 4 questions par défaut.
- [x] 2.2 Remplacer la case `_destroy` de `_contact_fields.html.erb` par un bouton « Supprimer » et un champ caché `_destroy`. Vérification : le formulaire de modification affiche le bouton sur chaque ligne enregistrée.

## 3. Contrôleur Stimulus

- [x] 3.1 Créer `app/javascript/controllers/nested_form_controller.js` avec les actions `add` (clone du `<template>`, remplacement de `NEW_RECORD` par un horodatage) et `remove` (ligne neuve retirée du DOM, ligne persistée masquée avec `_destroy=1`). Vérification : le contrôleur est chargé par `eagerLoadControllersFrom` sans modifier l'importmap.
- [x] 3.2 Brancher le contrôleur sur les trois fieldsets de `_form.html.erb`, chacun avec son `<template>` généré par le partial correspondant et un bouton « Ajouter ». Vérification : un clic sur « Ajouter » insère une ligne dans chacune des trois listes.

## 4. Lignes initiales

- [x] 4.1 Supprimer `BLANK_ROWS` dans `CampaignsController` et construire une ligne vide de managé et de sondé dans `new` et `edit`, sans ajouter de ligne vide supplémentaire après un échec de validation si la liste n'est pas vide. Vérification : tests d'intégration sur le nombre de lignes affichées à la création, à la modification et après un échec.

## 5. Tests

- [x] 5.1 Ajouter des tests d'intégration : création avec question ajoutée, question par défaut retirée, managé et sondé ajoutés ; modification avec suppression d'un élément enregistré ; ligne vide ignorée ; ré-affichage après erreur. Vérification : `bin/rails test test/integration/campaigns_test.rb` passe.
- [x] 5.2 Mettre à jour `test/system/feedback_journey_test.rb`, qui s'appuie sur les index fixes des 3 lignes vides, pour utiliser « Ajouter », et y couvrir l'ajout et la suppression d'une ligne. Vérification : `bin/rails test:system` passe.
- [x] 5.3 Lancer la suite complète. Vérification : `bin/rails test` sans échec.
