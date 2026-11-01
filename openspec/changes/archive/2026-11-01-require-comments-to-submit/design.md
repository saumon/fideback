# Design

## Context

- `Respondent#missing_ratings` renvoie les paires (managé, question) d'une question à note dont la note manque ; `submit!` refuse tant qu'il en reste. `RespondentFormsController#submit` enregistre la saisie, tente `submit!`, puis, en cas de refus, réaffiche `show` en 422 avec `@missing` et le message « Il manque des notes… ». La saisie réaffichée vient de `@input`.
- `Answer` nettoie le texte (`strip.presence`) et `Respondent#save_answers` supprime une réponse sans note ni texte : un commentaire « vide » ou fait d'espaces n'existe donc pas en base. « Manquant » se lit « pas de réponse avec du texte ».
- La vue `respondent_forms/show` est un seul formulaire avec deux boutons (« Enregistrer et continuer plus tard », « Soumettre définitivement » avec `formaction`). Aucun champ n'est `required`. La note est un champ numérique rempli aussi par des boutons 1 à 5 (contrôleur `rating`, qui affecte la valeur sans émettre d'événement).
- Le signalement actuel : classe `.answer.missing` (bande rouge à gauche) sur toute la réponse, et `<em class="error">Note manquante</em>`.
- Turbo met le focus sur le premier `[autofocus]` d'une page rendue, en ignorant les éléments d'une `<dialog>` fermée : la boîte de confirmation, rendue après le formulaire, ne gêne pas.
- La barre d'actions du formulaire (`.answer-actions`) est collée en bas de l'écran.
- Les tests créent leurs sondés soumis avec `update!(submitted_at:)` ; l'assistant `answer_fully` ne crée que des notes et ne suffira plus pour `submit!`.

## Goals / Non-Goals

**Goals:**
- Une seule définition de « manquant », côté serveur, qui fait foi ; l'annonce côté page n'est qu'une aide.
- Aucune migration, aucun réglage.
- Un formulaire qui dit la règle avant de refuser.

**Non-Goals:**
- Pas de validation côté navigateur qui remplacerait celle du serveur (`required`, bouton désactivé) : « Enregistrer » doit rester permissif et le serveur reste la règle.
- Pas de longueur minimale, pas d'option par question.

## Decisions

### 1. `missing_answers` : notes et commentaires, dans l'ordre de la page

`Respondent#missing_answers` remplace `missing_ratings` et renvoie des triplets `[managé, question, :rating | :body]`. Pour chaque managé à noter (triés par nom, comme la page) et chaque question dans l'ordre de la campagne, une note manque si la question a une note et que la réponse n'en porte pas, un commentaire manque si la question a un commentaire et que la réponse n'a pas de texte (`body.present?`). Dans une même question la note vient avant le commentaire, comme à l'écran, si bien que le premier triplet est le premier champ manquant de la page. Une seule requête charge les réponses du sondé.

`submit!` refuse si `missing_answers.any?`. Le critère « au moins un caractère qui n'est pas un espace » est celui qu'`Answer` applique déjà ; aucune règle de longueur n'est ajoutée.

*Écarté :* deux méthodes (notes, commentaires). Le contrôleur, la vue et le compteur ont besoin de la liste complète et de son ordre.

### 2. Un message qui compte

Le message d'alerte devient « Il manque N champs : complétez ceux qui sont signalés avant de soumettre. » (« Il manque 1 champ » au singulier). Le nombre est celui de `missing_answers`.

### 3. Mention, signalement par champ et focus

- Mention : une petite étiquette « obligatoire pour soumettre » à côté du libellé de chaque note et de chaque commentaire quand le formulaire est modifiable. Elle est hors du `<label>`, dont le texte ne change pas.
- Signalement : chaque triplet manquant affiche son propre message (`Note manquante` sous la note, `Commentaire manquant` sous le commentaire), ce qui remplace le test « la paire est manquante ». La bande rouge reste sur la réponse concernée.
- Focus : le champ du premier triplet porte `autofocus`, que Turbo applique après le rendu de la réponse 422. Turbo remet ensuite la page en haut : constaté dans une fenêtre courte, où le champ restait à 843 px dans une fenêtre de 400 px de haut. Le contrôleur `answer_progress` fait donc défiler la page jusqu'au champ en `autofocus` (centré, sur deux images d'animation pour passer après le rendu). Une règle `scroll-padding-bottom` sur la page du formulaire empêche la barre d'actions collée en bas de cacher le champ.

### 4. Compteur en direct, avec un état de départ rendu par le serveur

La barre d'actions affiche un `role="status"` : « Il reste N champs à renseigner » ou « Tout est renseigné : vous pouvez soumettre ». Le serveur rend l'état de départ (compté sur `missing_answers`), donc sans JavaScript le compteur est exact au chargement.

Un contrôleur Stimulus `answer_progress`, posé sur le formulaire, recompte à chaque événement `input` : un champ de note ou de commentaire marqué obligatoire est « renseigné » si sa valeur n'est pas vide après suppression des espaces. Le contrôleur `rating` émet un événement `input` quand un bouton 1 à 5 remplit la note, sans quoi le compteur ne le verrait pas. Le bouton « Soumettre définitivement » n'est jamais désactivé : le serveur reste la règle.

*Écarté :* désactiver le bouton tant qu'il manque un champ. Un bouton inerte sans explication est pire qu'un refus expliqué, et cela contredirait l'enregistrement partiel.

### 5. Données existantes

Aucune migration. Les sondés qui ont déjà soumis gardent leurs réponses telles quelles ; ceux qui ont enregistré des notes sans commentaires doivent les compléter à leur prochaine soumission.

## Risks / Trade-offs

- [Le compteur du navigateur et le serveur ne comptent pas la même chose] → Les deux partent des mêmes champs ; un test système compare le nombre annoncé au chargement, après saisie et après un refus avec le nombre de champs signalés.
- [Le nombre de commentaires à écrire est élevé (jusqu'à une dizaine avec les questions par défaut)] → Décision du propriétaire du produit ; la mention et le compteur le montrent avant la soumission, et « Enregistrer » permet de reprendre plus tard.
- [Un sondé en cours de campagne est bloqué par une règle qui n'existait pas quand il a commencé] → Décision du propriétaire du produit, écrite dans la spécification (scénario « Campagne déjà en cours »).
- [Le premier champ manquant reste hors écran ou sous la barre d'actions collée en bas] → Défilement explicite par le contrôleur et `scroll-padding-bottom` ; un test système dans une fenêtre de 600 px de haut vérifie que le champ focalisé est visible et au-dessus de la barre.
- [Un événement `input` ajouté à `rating` déclenche sa propre synchronisation en boucle] → Il n'y a pas de boucle : `sync` ne modifie que les boutons.

## Migration Plan

Aucune donnée ni migration. Déploiement ordinaire ; retour arrière par `git revert`, les sondés retrouvant l'obligation des seules notes.
