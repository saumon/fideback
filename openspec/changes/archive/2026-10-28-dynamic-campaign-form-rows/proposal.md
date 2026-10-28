# Proposal

## Why

Le formulaire de campagne ne permet pas d'ajouter une question : aucun champ vide n'est proposé, à la création comme à la modification. Les questions par défaut ne peuvent être retirées qu'en vidant leur texte, et la case « Supprimer » n'apparaît que pour les lignes déjà enregistrées. Managés et sondés sont limités à 3 lignes vides fixes.

## What Changes

- Les listes de questions, de managés et de sondés du formulaire de campagne (création et modification) gagnent un bouton « Ajouter » et un bouton « Supprimer » par ligne.
- Une ligne neuve supprimée disparaît du formulaire. Une ligne déjà enregistrée est masquée et marquée pour suppression, effective à l'enregistrement.
- Un seul contrôleur Stimulus générique, réutilisé sur les trois listes, clone un `<template>` généré par le partial de la ligne.
- Managés et sondés démarrent avec une ligne vide au lieu de 3. Les questions gardent les 4 par défaut à la création et n'affichent que les existantes à la modification.
- La position des questions est recalculée côté serveur selon l'ordre de soumission.
- Le modèle de données et les règles de validation ne changent pas.

## Capabilities

### New Capabilities

### Modified Capabilities
- `feedback-campaigns`: le formulaire de campagne permet d'ajouter et de supprimer des questions, des managés et des sondés avant le lancement.

## Impact

- `app/views/campaigns/_form.html.erb`, `_contact_fields.html.erb` et un nouveau partial de question.
- `app/controllers/campaigns_controller.rb` : suppression de `BLANK_ROWS`, une ligne vide par liste de contacts.
- `app/models/campaign.rb` ou `question.rb` : calcul de la position.
- `app/javascript/controllers/` : nouveau contrôleur Stimulus.
- `test/integration/campaigns_test.rb` et `test/system/` : couverture de l'ajout et de la suppression.
- Aucune dépendance ajoutée.
