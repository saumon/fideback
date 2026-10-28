# Design

## Context

Le formulaire (`campaigns/_form`) utilise des attributs imbriqués Rails (`accepts_nested_attributes_for` avec `allow_destroy` et un `reject_if` qui ignore les lignes vides). Le contrôleur ajoute 3 lignes vides de managés et de sondés via `BLANK_ROWS`. Les questions n'ont aucune ligne vide, et la case `_destroy` n'est rendue que pour les lignes enregistrées. Le projet n'a aucun contrôleur Stimulus réel (seulement `hello_controller`), avec importmap et `eagerLoadControllersFrom`. Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Un seul mécanisme d'ajout et de suppression pour les trois listes.
- Aucune duplication du balisage d'une ligne.
- Aucun changement de schéma ni de règle de validation.

**Non-Goals:**
- Réordonnancement par glisser-déposer des questions.
- Édition après lancement (toujours refusée).

## Decisions

**1. Contrôleur Stimulus générique `nested-form`.** Il porte un `<template>`, un conteneur de lignes, une action `add` et une action `remove`. Alternative écartée : Turbo Streams, qui impose un aller-retour serveur et la gestion d'un index côté serveur pour chaque ajout.

**2. Template généré par le partial de la ligne.** Chaque partial (`_contact_fields`, nouveau `_question_fields`) est rendu une fois avec un objet vide et l'index factice `NEW_RECORD` (`fields_for ..., child_index:`). `add` clone le template et remplace `NEW_RECORD` par un horodatage, ce qui garantit des index uniques.

**3. Suppression selon l'état de la ligne.** Une ligne sans `id` est retirée du DOM. Une ligne persistée est masquée et son champ caché `_destroy` passe à `1`. Le bouton remplace la case « Supprimer » actuelle.

**4. Lignes initiales.** `BLANK_ROWS` disparaît. `new`, `create` en échec et `edit` construisent une ligne vide de managé et de sondé. Les questions gardent `build_default_questions` à la création et ne reçoivent pas de ligne vide. Les lignes vides soumises sont ignorées par le `reject_if` existant.

**5. Position des questions côté serveur.** Un `before_validation` sur `Campaign` réaffecte `position` aux questions non marquées pour suppression, dans l'ordre de `questions` (celui de la soumission). Le champ caché `position` est retiré du formulaire. Alternative écartée : position calculée en JS, fragile après suppression.

**6. Ré-affichage après erreur.** Les lignes viennent des paramètres. Une ligne persistée marquée `_destroy` est rendue masquée. Aucune ligne vide supplémentaire n'est ajoutée si la liste n'est pas vide, pour éviter une accumulation à chaque échec.

## Risks / Trade-offs

- [Premier JS du projet, le comportement dynamique est difficile à couvrir par les tests d'intégration] → un test système (`test/system`) couvre l'ajout et la suppression ; les tests d'intégration vérifient la soumission de paramètres équivalents.
- [Le test système existant repose sur les index fixes des 3 lignes vides] → à adapter pour cliquer sur « Ajouter ».
- [Un nouveau contrôleur sans pin explicite : `pin_all_from` le charge déjà] → aucune modification d'importmap attendue ; à vérifier.
- [Sans JS, plus de ligne à ajouter] → accepté, l'application repose déjà sur Turbo.
