# admin-area Specification

## Purpose

Réserver à l'Admin du site un espace d'administration, atteint depuis un lien de menu qu'il est seul à voir, qui accueillera les futures actions d'administration.

## Requirements

### Requirement: Rôle des managers
Le système SHALL attribuer à chaque manager un rôle, `manager` ou `admin`. Un compte créé sans attribution particulière SHALL avoir le rôle `manager`.

#### Scenario: Rôle par défaut
- **WHEN** un manager est créé alors que d'autres managers existent déjà
- **THEN** son rôle est `manager`

### Requirement: Espace d'administration réservé à l'Admin
Le système SHALL n'autoriser l'accès à l'espace d'administration qu'à un manager connecté ayant le rôle `admin`. Pour tout autre manager connecté, il SHALL répondre comme si la page n'existait pas.

#### Scenario: Accès par un Admin
- **WHEN** un Admin connecté ouvre l'espace d'administration
- **THEN** l'écran d'administration s'affiche

#### Scenario: Accès par un manager non Admin
- **WHEN** un manager connecté sans le rôle `admin` ouvre l'espace d'administration
- **THEN** la réponse est une page introuvable (404), identique à celle d'une adresse inexistante

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté ouvre l'espace d'administration
- **THEN** il est redirigé vers la page de connexion

### Requirement: Lien de menu vers l'administration
Le système SHALL afficher dans la navigation principale un lien « Administration » menant à l'espace d'administration, visible uniquement pour un Admin connecté.

#### Scenario: Menu d'un Admin
- **WHEN** un Admin connecté consulte une page de l'application
- **THEN** la navigation contient le lien « Administration », qui mène à l'écran d'administration

#### Scenario: Menu d'un manager non Admin
- **WHEN** un manager connecté sans le rôle `admin` consulte une page de l'application
- **THEN** la navigation ne contient pas le lien « Administration »

#### Scenario: Menu d'un visiteur
- **WHEN** un visiteur non connecté consulte une page de l'application
- **THEN** la navigation ne contient pas le lien « Administration »

### Requirement: Écran d'administration sans action
Le système SHALL présenter un écran d'administration titré « Administration » dont la seule action est un bouton « Utilisateurs » menant à l'écran des utilisateurs.

#### Scenario: Contenu de l'écran
- **WHEN** un Admin ouvre l'écran d'administration
- **THEN** l'écran porte le titre « Administration » et ne contient aucun formulaire

#### Scenario: Bouton Utilisateurs
- **WHEN** un Admin ouvre l'écran d'administration
- **THEN** l'écran contient un bouton « Utilisateurs » qui mène à l'écran des utilisateurs
