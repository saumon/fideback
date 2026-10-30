# admin-users Specification

## Purpose

Donner à l'Admin du site une vue en lecture seule des managers inscrits, y compris ceux qui n'ont pas encore activé leur compte.

## Requirements

### Requirement: Écran des utilisateurs réservé à l'Admin
Le système SHALL n'autoriser l'accès à l'écran des utilisateurs qu'à un manager connecté ayant le rôle `admin`. Pour tout autre manager connecté, il SHALL répondre comme si la page n'existait pas.

#### Scenario: Accès par un Admin
- **WHEN** un Admin connecté ouvre l'écran des utilisateurs
- **THEN** l'écran titré « Utilisateurs » s'affiche

#### Scenario: Accès par un manager non Admin
- **WHEN** un manager connecté sans le rôle `admin` ouvre l'écran des utilisateurs
- **THEN** la réponse est une page introuvable (404), identique à celle d'une adresse inexistante

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté ouvre l'écran des utilisateurs
- **THEN** il est redirigé vers la page de connexion

### Requirement: Liste des managers inscrits
Le système SHALL lister sur l'écran des utilisateurs tous les managers inscrits, avec pour chacun son nom, son e-mail, son rôle (« Manager » ou « Admin ») et sa date d'inscription.

#### Scenario: Contenu d'une ligne
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** chaque manager inscrit apparaît une fois, avec son nom, son e-mail, son rôle et sa date d'inscription

#### Scenario: Rôles affichés
- **WHEN** la liste contient un Admin et un manager
- **THEN** le premier est présenté comme « Admin » et le second comme « Manager »

### Requirement: Comptes non confirmés signalés
Le système SHALL inclure dans la liste les managers qui n'ont pas encore confirmé leur compte et SHALL les signaler par un badge « Non confirmé ». Un compte confirmé SHALL NOT porter ce badge.

#### Scenario: Compte non confirmé
- **WHEN** un manager inscrit n'a pas cliqué sur son lien d'activation
- **THEN** il figure dans la liste avec le badge « Non confirmé »

#### Scenario: Compte confirmé
- **WHEN** un manager a confirmé son compte
- **THEN** il figure dans la liste sans badge « Non confirmé »

### Requirement: Ordre de la liste
Le système SHALL trier la liste des utilisateurs par date d'inscription décroissante, le plus récent en premier.

#### Scenario: Tri par inscription
- **WHEN** trois managers se sont inscrits à des dates différentes
- **THEN** le plus récemment inscrit apparaît en premier et le plus ancien en dernier

### Requirement: Écran en lecture seule
Le système SHALL présenter l'écran des utilisateurs sans aucune action sur les comptes (suppression, changement de rôle ou autre), et SHALL y offrir un lien de retour vers l'écran « Administration ».

#### Scenario: Aucune action sur les comptes
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** l'écran ne contient ni formulaire ni bouton d'action sur les comptes

#### Scenario: Retour à l'administration
- **WHEN** un Admin suit le lien de retour de l'écran des utilisateurs
- **THEN** l'écran « Administration » s'affiche
