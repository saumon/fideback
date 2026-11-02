# Design

## Context

Un contact existant est une `.pick` : bordure de 2px, case à cocher, et, une fois cochée, fond teinté par `--pick` (safran pour les managés, rose pour les sondés), bordure `--ink` et ombre portée. Un nouveau contact est une `.field.contact`, une grille de deux champs et d'un bouton « Supprimer », sans habillage. Le partial est rendu à la fois pour les lignes déjà présentes (campagne refusée à l'enregistrement) et pour le `<template>` du contrôleur `nested-form`.

## Goals / Non-Goals

**Goals:**
- Donner à la ligne de nouveau contact le même rendu qu'une fiche cochée.
- Conserver le rendu d'erreur (bordure `--danger` sur les champs).

**Non-Goals:**
- Rendre la case interactive ou exclure un contact sans le supprimer.
- Modifier le modèle, le contrôleur ou les paramètres envoyés.

## Decisions

- **Case réelle, cochée, non interactive, sans `name`** : un `input[type=checkbox]` avec `checked`, `aria-hidden="true"` et `tabindex="-1"`, rendu inerte par `pointer-events: none`. Sans `name`, elle n'est jamais soumise, donc aucun paramètre ne s'ajoute. Elle n'est pas `disabled` : Chrome grise une case désactivée, ce qui l'éloignerait de la case d'un contact existant. Alternative écartée : un faux indicateur en CSS pur, qui ne ressemblerait pas à la case du navigateur.
- **Styles partagés plutôt que copiés** : `.contact` reprend les déclarations de `.pick:has(:checked)` (bordure `--ink`, fond `color-mix` avec `--pick`, ombre, décalage) via une règle commune, pour que les deux fiches ne divergent pas.
- **Grille** : ajouter une première colonne `auto` pour la case, avant Nom, E-mail et « Supprimer ». Sur mobile, la case et « Supprimer » restent alignés sur les deux rangées de champs.
- **Erreur** : `.contact.has-error` garde la bordure `--danger` sur les champs ; la fiche reste teintée.

## Risks / Trade-offs

- [Une case cochée qui ne réagit pas peut être prise pour un défaut] → elle ne réagit pas au clic et n'est pas dans l'ordre de tabulation, et le bouton « Supprimer » reste visible à côté.
- [Divergence de style avec `.pick`] → déclarations partagées dans une seule règle.
