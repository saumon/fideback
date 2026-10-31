# Spec Delta

## ADDED Requirements

### Requirement: État de la connexion par lien unique
Le système SHALL afficher sur l'écran « Danger zone » un bloc « Connexion par lien unique » indiquant si l'option est activée ou désactivée, et rappelant que le lien est valable 10 minutes et ne sert qu'une fois. L'option SHALL être désactivée tant que l'Admin ne l'a pas activée.

#### Scenario: Désactivée par défaut
- **WHEN** un Admin ouvre l'écran « Danger zone » sans avoir jamais modifié ce réglage
- **THEN** le bloc indique que la connexion par lien unique est désactivée

#### Scenario: Activée
- **WHEN** un Admin ouvre l'écran après avoir activé l'option
- **THEN** le bloc indique qu'elle est activée et propose de la désactiver

### Requirement: Activation avec confirmation
Le système SHALL n'activer la connexion par lien unique qu'après une confirmation explicite de l'Admin, qui l'avertit qu'une panne d'envoi d'e-mails empêcherait toute connexion, que les sessions ouvertes restent valables, et que « Se souvenir de moi » et la connexion après réinitialisation sont coupés.

#### Scenario: Activation confirmée
- **WHEN** l'Admin demande l'activation puis la confirme
- **THEN** l'option est activée, l'écran affiche l'état « activée » et une notice confirme l'activation

#### Scenario: Activation annulée
- **WHEN** l'Admin demande l'activation puis l'annule
- **THEN** l'option reste désactivée et l'écran revient à son état normal

#### Scenario: Activation sans JavaScript
- **WHEN** l'Admin demande l'activation dans un navigateur sans JavaScript
- **THEN** la confirmation s'affiche dans la page et l'activation reste possible

### Requirement: Désactivation immédiate
Le système SHALL permettre à l'Admin de désactiver la connexion par lien unique sans confirmation, ce qui rétablit la connexion par mot de passe seul.

#### Scenario: Désactivation
- **WHEN** l'Admin désactive l'option alors qu'elle est activée
- **THEN** l'option est désactivée, l'écran affiche l'état « désactivée » et une notice confirme la désactivation

### Requirement: Réglage de connexion conservé
Le système SHALL conserver le réglage de la connexion par lien unique d'une session et d'un redémarrage à l'autre et l'appliquer à tous les managers. Les deux réglages de l'écran SHALL être modifiables indépendamment l'un de l'autre.

#### Scenario: Réglage conservé
- **WHEN** l'Admin active l'option puis que l'application redémarre
- **THEN** la connexion par lien unique reste activée pour tous les managers

#### Scenario: Réglages indépendants
- **WHEN** l'Admin ferme les inscriptions alors que la connexion par lien est activée
- **THEN** la connexion par lien reste activée
