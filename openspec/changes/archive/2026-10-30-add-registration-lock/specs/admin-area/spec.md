# Spec Delta

## MODIFIED Requirements

### Requirement: Écran d'administration sans action
Le système SHALL présenter un écran d'administration titré « Administration » dont les seules actions sont un bouton « Utilisateurs » menant à l'écran des utilisateurs et un bouton « Danger zone » menant à l'écran du même nom.

#### Scenario: Contenu de l'écran
- **WHEN** un Admin ouvre l'écran d'administration
- **THEN** l'écran porte le titre « Administration » et ne contient aucun formulaire

#### Scenario: Bouton Utilisateurs
- **WHEN** un Admin ouvre l'écran d'administration
- **THEN** l'écran contient un bouton « Utilisateurs » qui mène à l'écran des utilisateurs

#### Scenario: Bouton Danger zone
- **WHEN** un Admin ouvre l'écran d'administration
- **THEN** l'écran contient un bouton « Danger zone » qui mène à l'écran « Danger zone »
