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
Le système SHALL permettre au sondé de soumettre définitivement ses réponses, après quoi elles ne sont plus modifiables.

#### Scenario: Soumission complète
- **WHEN** un sondé a renseigné toutes les notes et tous les commentaires requis pour tous les managés et soumet
- **THEN** son statut passe à « a répondu » et le formulaire devient en lecture seule

#### Scenario: Réponses manquantes
- **WHEN** un sondé soumet alors que des notes sont manquantes
- **THEN** la soumission est refusée et les champs manquants sont signalés

### Requirement: Fermeture des réponses
Le système SHALL refuser toute modification de réponse lorsque la campagne est clôturée ou la date limite dépassée.

#### Scenario: Campagne clôturée
- **WHEN** un sondé ouvre son lien après la clôture de la campagne
- **THEN** il voit un message indiquant que la campagne est terminée et ne peut rien saisir
