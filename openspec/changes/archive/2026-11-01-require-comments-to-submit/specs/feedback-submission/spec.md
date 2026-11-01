# Spec Delta

## MODIFIED Requirements

### Requirement: Soumission finale
Le système SHALL permettre au sondé de soumettre définitivement ses réponses, après quoi elles ne sont plus modifiables, à condition qu'il ait renseigné toutes les notes et tous les commentaires que les questions attendent, pour chaque managé sur lequel il répond.

#### Scenario: Soumission complète
- **WHEN** un sondé a renseigné toutes les notes et tous les commentaires requis pour tous les managés et soumet
- **THEN** son statut passe à « a répondu » et le formulaire devient en lecture seule

#### Scenario: Réponses manquantes
- **WHEN** un sondé soumet alors que des notes ou des commentaires sont manquants
- **THEN** la soumission est refusée et les champs manquants sont signalés

#### Scenario: Commentaire manquant
- **WHEN** un sondé a renseigné toutes les notes mais laisse vide le commentaire d'une question à commentaire pour un managé, et soumet
- **THEN** la soumission est refusée, le champ est signalé « Commentaire manquant » et son statut ne change pas

#### Scenario: Question à commentaire seul
- **WHEN** un sondé laisse vide le commentaire d'une question qui n'a pas de note, et soumet
- **THEN** la soumission est refusée comme pour une question à note et commentaire

#### Scenario: Commentaire fait d'espaces
- **WHEN** un sondé saisit seulement des espaces ou des retours à la ligne dans un commentaire et soumet
- **THEN** ce commentaire est considéré comme manquant et la soumission est refusée

#### Scenario: Commentaire très court
- **WHEN** un sondé saisit « ok » dans chaque commentaire attendu et soumet avec toutes les notes
- **THEN** la soumission est acceptée

#### Scenario: Enregistrement sans soumettre
- **WHEN** un sondé enregistre sa progression avec des notes et des commentaires encore manquants
- **THEN** la saisie est conservée sans refus et il peut la reprendre plus tard

#### Scenario: Campagne déjà en cours
- **WHEN** un sondé avait enregistré des notes sans commentaires avant la mise en service de la règle et soumet
- **THEN** la soumission est refusée tant qu'il n'a pas renseigné les commentaires manquants, alors qu'un sondé ayant déjà soumis n'est pas concerné

## ADDED Requirements

### Requirement: Champs obligatoires annoncés
Le système SHALL indiquer au sondé, avant toute soumission, que chaque note et chaque commentaire est obligatoire pour soumettre, et afficher le nombre de champs obligatoires qu'il lui reste à renseigner, mis à jour pendant sa saisie.

#### Scenario: Mention sur chaque champ
- **WHEN** un sondé ouvre son lien d'une campagne en cours
- **THEN** chaque note et chaque commentaire porte la mention « obligatoire pour soumettre »

#### Scenario: Compteur au départ
- **WHEN** un sondé ouvre son formulaire sans rien avoir saisi, pour deux managés et deux questions dont une à note et commentaire et une à commentaire seul
- **THEN** le compteur annonce 6 champs à renseigner

#### Scenario: Compteur pendant la saisie
- **WHEN** le sondé renseigne une note ou écrit un commentaire
- **THEN** le compteur diminue d'un champ sans recharger la page, et il remonte si le sondé efface ce commentaire

#### Scenario: Tout est renseigné
- **WHEN** le sondé a renseigné tous les champs
- **THEN** le compteur indique qu'il ne reste rien à renseigner

### Requirement: Champs manquants signalés après un refus
Le système SHALL, quand une soumission est refusée faute de notes ou de commentaires, annoncer le nombre de champs manquants, signaler chacun d'eux (« Note manquante », « Commentaire manquant »), conserver la saisie et placer le focus sur le premier champ manquant.

#### Scenario: Message et signalement
- **WHEN** un sondé soumet avec 3 champs manquants
- **THEN** le message annonce 3 champs manquants et chacun de ces champs porte son signalement, les champs remplis n'en portant aucun

#### Scenario: Saisie conservée
- **WHEN** la soumission est refusée
- **THEN** les notes et les commentaires déjà saisis sont toujours dans le formulaire

#### Scenario: Premier champ manquant
- **WHEN** la soumission est refusée
- **THEN** le focus est sur le premier champ manquant, dans l'ordre de la page, et la page est positionnée pour le voir
