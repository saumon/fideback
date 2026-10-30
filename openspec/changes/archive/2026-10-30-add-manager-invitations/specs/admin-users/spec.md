# Spec Delta

## MODIFIED Requirements

### Requirement: Écran en lecture seule
Le système SHALL présenter l'écran des utilisateurs sans aucune action sur les comptes existants (suppression, changement de rôle ou autre), ses seules actions portant sur les invitations, et SHALL y offrir un lien de retour vers l'écran « Administration ».

#### Scenario: Aucune action sur les comptes
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** l'écran ne propose aucune action de suppression ni de changement de rôle sur les comptes de la liste des managers

#### Scenario: Actions sur les invitations
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** l'écran propose le bouton « Inviter un manager » et, pour chaque invitation non acceptée, « Renvoyer » et « Annuler »

#### Scenario: Retour à l'administration
- **WHEN** un Admin suit le lien de retour de l'écran des utilisateurs
- **THEN** l'écran « Administration » s'affiche
