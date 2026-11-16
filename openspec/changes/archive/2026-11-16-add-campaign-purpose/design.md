# Design

## Context

`Campaign` n'a que `name` et `deadline_on` comme champs saisis. Le formulaire de campagne (`campaigns/_form`) sert à la création et à la modification en brouillon ; `content_frozen_once_launched` ne gèle que managés, sondés et questions. L'e-mail d'invitation (`respondent_mailer/invitation`) existe en HTML et en texte ; la page sondé est `respondent_forms/show`.

## Goals / Non-Goals

**Goals:**
- Un champ unique, facultatif, affiché de façon identique sur la page et dans l'e-mail.

**Non-Goals:**
- Pas de mise en forme riche (Markdown, HTML) dans le motif.
- Pas de réécriture des autres textes évoquant les entretiens individuels (accueil, invitation de manager).

## Decisions

- **Colonne `purpose` de type `text`, nullable, sans valeur par défaut.** Une chaîne vide et `nil` sont tous deux « sans motif » : l'affichage teste `purpose.present?`, ce qui écarte aussi un texte fait d'espaces. Alternative écartée : table séparée, disproportionnée pour un champ.
- **Validation `length: { maximum: 1000 }` sur le modèle**, sans `allow_nil` à ajouter (nil passe). Un `maxlength` sur le champ HTML aide la saisie, mais la règle reste côté serveur.
- **Modifiable en brouillon seulement, sans nouveau verrou.** Le bouton « Modifier » n'existe déjà que pour une campagne brouillon ; le motif n'est pas ajouté à `content_frozen_once_launched`, car modifier un texte d'information ne change pas le contenu des réponses. Il reste donc cohérent entre e-mail et page tant que personne n'est invité.
- **Rendu par `simple_format`** (échappe le HTML, conserve les retours à la ligne) sur la page. Dans l'e-mail HTML, même rendu ; en texte, le motif brut. Alternative écartée : `raw` ou `sanitize`, inutiles pour du texte saisi.
- **Phrase d'e-mail neutre** : « <manager> vous invite à donner votre feedback dans la campagne « <nom> ». » Le motif vient dans un bloc séparé, avec le titre « Pourquoi cette campagne ? », après cette phrase.
- **Libellé du champ via `fr.yml`** (`activerecord.attributes.campaign.purpose`), comme `deadline_on`, pour que les messages d'erreur le citent correctement.

## Risks / Trade-offs

- [Un motif long alourdit l'e-mail] → plafond de 1000 caractères.
- [Le motif est modifiable jusqu'au lancement, donc un sondé ne le voit jamais changer] → sans objet : aucune invitation n'est partie avant le lancement.
- [Le style de la page sondé est coloré et animé (préférence du projet)] → le bloc reprend les classes existantes de `respondent-intro` plutôt qu'un style sobre isolé.

## Migration Plan

Migration `add_column :campaigns, :purpose, :text`, sans remplissage : les campagnes existantes n'ont pas de motif et s'affichent comme avant. Retour arrière : suppression de la colonne.
