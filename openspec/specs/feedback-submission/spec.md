# feedback-submission Specification

## Purpose

Permettre aux sondés de répondre au questionnaire pour chaque managé via un lien personnel, sans créer de compte.

## Requirements

### Requirement: Invitation par e-mail
Le système SHALL envoyer à chaque sondé, au lancement de la campagne, un e-mail contenant un lien personnel non devinable.

#### Scenario: Envoi des invitations
- **WHEN** un manager lance une campagne
- **THEN** chaque sondé reçoit un e-mail avec son lien personnel, le nom du manager et la date limite

### Requirement: Accès par lien personnel
Le système SHALL donner accès au formulaire de réponse à toute personne disposant du lien valide d'un sondé, sans authentification, et uniquement pour la campagne et le sondé concernés.

#### Scenario: Lien valide
- **WHEN** un sondé ouvre son lien pendant que la campagne est en cours
- **THEN** il voit la liste des managés sur lesquels il doit répondre, hors lui-même

#### Scenario: Lien invalide
- **WHEN** quelqu'un ouvre un lien dont le jeton est inconnu
- **THEN** le système répond comme si la page n'existait pas

### Requirement: Saisie des réponses
Le système SHALL permettre au sondé de répondre à chaque question pour chaque managé (note et/ou commentaire selon la question), d'enregistrer sa progression et de la reprendre ultérieurement.

#### Scenario: Enregistrement partiel
- **WHEN** un sondé répond pour un seul managé et quitte la page
- **THEN** ses réponses sont conservées et il les retrouve en rouvrant son lien

#### Scenario: Note hors limites
- **WHEN** un sondé soumet une note différente d'un entier entre 1 et 5
- **THEN** la réponse est refusée avec un message d'erreur

#### Scenario: Question à note et commentaire
- **WHEN** une question comporte une note et un commentaire
- **THEN** le sondé peut saisir les deux pour chaque managé

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

### Requirement: Fermeture des réponses
Le système SHALL refuser toute modification de réponse lorsque la campagne est clôturée ou la date limite dépassée.

#### Scenario: Campagne clôturée
- **WHEN** un sondé ouvre son lien après la clôture de la campagne
- **THEN** il voit un message indiquant que la campagne est terminée et ne peut rien saisir

### Requirement: Confirmation au sondé dont la soumission clôt la campagne
Le système SHALL montrer au sondé dont la soumission clôture la campagne la même confirmation qu'à tout autre sondé qui soumet, et MUST NOT lui indiquer que la campagne est terminée comme s'il arrivait trop tard.

#### Scenario: Dernier sondé
- **WHEN** le dernier sondé soumet et que la campagne se clôture
- **THEN** il voit « Merci ! Vos réponses ont été soumises » et le message « Vous avez soumis vos réponses », sans le message de campagne terminée

#### Scenario: Retour sur son lien
- **WHEN** ce sondé rouvre son lien après la clôture
- **THEN** il voit toujours qu'il a soumis ses réponses, en lecture seule

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
