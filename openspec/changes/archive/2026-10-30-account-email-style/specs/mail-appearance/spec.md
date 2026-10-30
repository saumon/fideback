# Spec Delta

## Purpose

Donne à tous les e-mails envoyés par Fideback, aux sondés comme aux managers, la même apparence reconnaissable, pour que le destinataire identifie l'expéditeur avant de suivre un lien.

## ADDED Requirements

### Requirement: Habillage commun des e-mails
Le système SHALL présenter la version HTML de chacun de ses e-mails dans le même habillage : fond clair, nom « Fideback » en tête, bandeau aux six couleurs de l'application, puis le message dans une carte blanche bordée d'encre. Le bouton d'action MUST avoir le même style dans tous les e-mails.

#### Scenario: Invitation d'un sondé
- **WHEN** une campagne démarre et qu'un sondé reçoit son invitation
- **THEN** l'e-mail affiche l'en-tête « Fideback », le bandeau coloré et la carte bordée d'encre

#### Scenario: Activation d'un compte manager
- **WHEN** un visiteur crée un compte manager et reçoit l'e-mail d'activation
- **THEN** l'e-mail présente le même habillage que l'invitation d'un sondé, avec le bouton « Activer mon compte » au même style

#### Scenario: Confirmation d'une nouvelle adresse
- **WHEN** un manager modifie l'adresse e-mail de son compte et reçoit l'e-mail de confirmation à la nouvelle adresse
- **THEN** l'e-mail présente le même habillage que l'invitation d'un sondé

#### Scenario: Réinitialisation du mot de passe
- **WHEN** un manager demande à réinitialiser son mot de passe
- **THEN** l'e-mail reçu présente le même habillage que l'invitation d'un sondé, avec le bouton « Changer mon mot de passe » au même style

### Requirement: Version texte des e-mails
Le système SHALL joindre à chacun de ses e-mails une version texte, sans mise en forme, qui reprend le message et l'adresse complète du lien d'action. Les messageries qui n'affichent pas le HTML l'utiliseront.

#### Scenario: Réinitialisation du mot de passe en texte
- **WHEN** un manager demande à réinitialiser son mot de passe
- **THEN** l'e-mail contient une version texte et une version HTML, et la version texte donne l'adresse complète du lien de réinitialisation

#### Scenario: Activation en texte
- **WHEN** un visiteur reçoit l'e-mail d'activation de son compte
- **THEN** l'e-mail contient une version texte et une version HTML, et la version texte donne l'adresse complète du lien d'activation

### Requirement: Salutation par le nom
Le système SHALL saluer le destinataire d'un e-mail par son nom, sous la forme « Bonjour <nom>, », et MUST ne pas utiliser son adresse e-mail comme salutation.

#### Scenario: Réinitialisation du mot de passe
- **WHEN** le manager Alice Manager demande à réinitialiser son mot de passe
- **THEN** l'e-mail commence par « Bonjour Alice Manager, » dans ses deux versions

#### Scenario: Activation
- **WHEN** le visiteur Alice Manager crée son compte
- **THEN** l'e-mail d'activation commence par « Bonjour Alice Manager, »
