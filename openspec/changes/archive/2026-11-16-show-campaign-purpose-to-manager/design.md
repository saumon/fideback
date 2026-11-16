# Design

## Context

Le bloc du motif existe déjà côté sondé (`respondent_forms/show`) : section `.campaign-purpose`, titre, texte échappé par `simple_format(h(...), {}, sanitize: false)`, style bleu avec petite animation d'entrée. La page `campaigns/show` ouvre sur `.page-head` (nom, statut, date limite), puis un éventuel avis de clôture et les boutons d'action. Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Un seul endroit définit le bloc, pour que les deux pages restent identiques.

**Non-Goals:**
- Pas de modification du motif depuis cette page.
- Pas d'affichage dans la liste des campagnes.

## Decisions

- **Partiel partagé `campaigns/_purpose`** reçoit la campagne et ne rend rien si `purpose` est vide ou blanc. Les deux pages l'appellent, ce qui garantit le même titre, le même échappement et le même test `present?`. Alternative écartée : recopier le balisage dans `campaigns/show`, qui laisserait deux copies à tenir à jour.
- **Emplacement** : juste après `.page-head`, avant l'avis « Clôturée : tous les sondés ont répondu » et avant les boutons. Le manager lit le motif avec le titre, comme le sondé, puis arrive aux actions.
- **Aucun rappel si vide** : le champ est facultatif, aucun texte de substitution ni lien « Modifier » n'est ajouté.
- **Style réutilisé** : la classe `.campaign-purpose` ne dépend pas de la page du sondé. Seul son emplacement dans la feuille change, de la section « Formulaire du sondé » vers un endroit commun, avec un espacement bas suffisant pour que la page de campagne n'ait pas le bloc collé aux boutons. Un `id` de titre fixe (`campaign-purpose-title`) suffit : une seule occurrence par page.

## Risks / Trade-offs

- [Le bloc coloré peut paraître lourd à côté des boutons d'action] → l'espacement est vérifié visuellement dans l'application, sur grand écran et sous 40rem.
- [Le déplacement du CSS casse la page du sondé] → les tests existants de la page sondé et une vérification visuelle couvrent ce risque.
