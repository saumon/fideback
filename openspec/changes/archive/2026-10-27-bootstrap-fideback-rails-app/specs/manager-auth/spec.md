# Spec Delta

## Purpose

Permettre aux managers de disposer d'un compte personnel sécurisé afin que seuls les utilisateurs authentifiés accèdent à leurs campagnes et aux feedbacks associés.

## ADDED Requirements

### Requirement: Inscription d'un manager
Le système SHALL permettre à un visiteur de créer un compte manager avec un nom, un e-mail unique et un mot de passe.

#### Scenario: Inscription valide
- **WHEN** un visiteur soumet un nom, un e-mail inconnu et un mot de passe valide
- **THEN** un compte est créé et le manager est connecté et redirigé vers la liste de ses campagnes

#### Scenario: E-mail déjà utilisé
- **WHEN** un visiteur soumet un e-mail déjà associé à un compte
- **THEN** aucun compte n'est créé et une erreur est affichée

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

### Requirement: Réinitialisation du mot de passe
Le système SHALL permettre à un manager de réinitialiser son mot de passe via un lien envoyé par e-mail.

#### Scenario: Demande de réinitialisation
- **WHEN** un manager saisit l'e-mail de son compte sur la page de mot de passe oublié
- **THEN** un e-mail contenant un lien de réinitialisation à durée limitée lui est envoyé

#### Scenario: E-mail inconnu
- **WHEN** un visiteur saisit un e-mail sans compte
- **THEN** la réponse affichée est identique à celle d'un e-mail connu, sans révéler l'existence du compte

### Requirement: Accès réservé aux managers authentifiés
Le système SHALL refuser l'accès aux pages de gestion de campagnes à tout visiteur non authentifié.

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté demande la liste des campagnes
- **THEN** il est redirigé vers la page de connexion
