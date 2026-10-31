# Spec Delta

## MODIFIED Requirements

### Requirement: Connexion et déconnexion
Le système SHALL authentifier un manager par e-mail et mot de passe et lui permettre de se déconnecter.

#### Scenario: Identifiants valides
- **WHEN** un manager soumet un e-mail et un mot de passe corrects
- **THEN** il est connecté et redirigé vers la liste de ses campagnes

#### Scenario: Identifiants invalides
- **WHEN** un manager soumet un mot de passe incorrect
- **THEN** il reste non connecté et un message d'erreur générique est affiché

#### Scenario: Déconnexion
- **WHEN** un manager connecté se déconnecte
- **THEN** sa session est terminée et il est redirigé vers la page de connexion

#### Scenario: Connexion par lien unique activée
- **WHEN** un manager soumet un e-mail et un mot de passe corrects alors que la connexion par lien unique est activée
- **THEN** il n'est pas connecté tant qu'il n'a pas suivi le lien reçu par e-mail

### Requirement: Réinitialisation du mot de passe
Le système SHALL permettre à un manager de réinitialiser son mot de passe via un lien envoyé par e-mail.

#### Scenario: Demande de réinitialisation
- **WHEN** un manager saisit l'e-mail de son compte sur la page de mot de passe oublié
- **THEN** un e-mail contenant un lien de réinitialisation à durée limitée lui est envoyé

#### Scenario: E-mail inconnu
- **WHEN** un visiteur saisit un e-mail sans compte
- **THEN** la réponse affichée est identique à celle d'un e-mail connu, sans révéler l'existence du compte

#### Scenario: Bouton de demande lisible
- **WHEN** un visiteur ouvre la page de mot de passe oublié, sur ordinateur ou sur un écran de téléphone de 360 px de large
- **THEN** le bouton d'envoi s'intitule « Envoyez-moi les instructions » et tient entièrement dans la carte du formulaire, sans texte coupé

#### Scenario: Nouveau mot de passe avec la connexion par lien activée
- **WHEN** un manager choisit un nouveau mot de passe alors que la connexion par lien unique est activée
- **THEN** le mot de passe est changé, aucune session n'est ouverte et il est renvoyé vers la page de connexion
