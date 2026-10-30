# Spec Delta

## Purpose

Donner à l'Admin du site un écran réservé pour ouvrir ou fermer les inscriptions de nouveaux utilisateurs, et conserver ce choix.

## ADDED Requirements

### Requirement: Écran Danger zone réservé à l'Admin
Le système SHALL n'autoriser l'accès à l'écran « Danger zone » qu'à un manager connecté ayant le rôle `admin`. Pour tout autre manager connecté, il SHALL répondre comme si la page n'existait pas.

#### Scenario: Accès par un Admin
- **WHEN** un Admin connecté ouvre l'écran « Danger zone »
- **THEN** l'écran titré « Danger zone » s'affiche

#### Scenario: Accès par un manager non Admin
- **WHEN** un manager connecté sans le rôle `admin` ouvre l'écran « Danger zone » ou tente de modifier le réglage
- **THEN** la réponse est une page introuvable (404), identique à celle d'une adresse inexistante, et le réglage n'est pas modifié

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté ouvre l'écran « Danger zone »
- **THEN** il est redirigé vers la page de connexion

### Requirement: État des inscriptions
Le système SHALL afficher sur l'écran « Danger zone » si les inscriptions sont ouvertes ou fermées, et SHALL signaler que l'inscription reste possible tant qu'aucun manager n'existe. Les inscriptions SHALL être ouvertes tant que l'Admin ne les a pas fermées.

#### Scenario: Inscriptions ouvertes par défaut
- **WHEN** un Admin ouvre l'écran « Danger zone » sans avoir jamais modifié le réglage
- **THEN** l'écran indique que les inscriptions sont ouvertes

#### Scenario: Inscriptions fermées
- **WHEN** un Admin ouvre l'écran après avoir fermé les inscriptions
- **THEN** l'écran indique que les inscriptions sont fermées

### Requirement: Désactivation avec confirmation
Le système SHALL ne fermer les inscriptions qu'après une confirmation explicite de l'Admin, qui rappelle que les comptes existants ne changent pas. Annuler la confirmation SHALL laisser les inscriptions ouvertes.

#### Scenario: Désactivation confirmée
- **WHEN** l'Admin demande la désactivation puis la confirme
- **THEN** les inscriptions sont fermées, l'écran affiche l'état « fermées » et une notice confirme la désactivation

#### Scenario: Désactivation annulée
- **WHEN** l'Admin demande la désactivation puis l'annule
- **THEN** les inscriptions restent ouvertes et l'écran revient à son état normal

#### Scenario: Désactivation sans JavaScript
- **WHEN** l'Admin demande la désactivation dans un navigateur sans JavaScript
- **THEN** la confirmation s'affiche dans la page et la désactivation reste possible

### Requirement: Réactivation
Le système SHALL permettre à l'Admin de rouvrir les inscriptions sans confirmation, depuis l'écran « Danger zone ».

#### Scenario: Réactivation
- **WHEN** l'Admin réactive les inscriptions alors qu'elles sont fermées
- **THEN** les inscriptions sont ouvertes, l'écran affiche l'état « ouvertes » et une notice confirme la réactivation

### Requirement: Réglage conservé
Le système SHALL conserver le réglage des inscriptions d'une session et d'un redémarrage à l'autre, et l'appliquer à tous les visiteurs.

#### Scenario: Réglage conservé
- **WHEN** l'Admin ferme les inscriptions puis que l'application redémarre
- **THEN** les inscriptions restent fermées pour tous les visiteurs
