# Spec Delta

## ADDED Requirements

### Requirement: Inscriptions fermées par l'Admin
Lorsque l'Admin a fermé les inscriptions et qu'au moins un manager existe, le système SHALL refuser toute inscription : l'ouverture de la page d'inscription comme l'envoi de son formulaire ramènent le visiteur à l'accueil avec un toast d'avertissement « Les inscriptions sont fermées pour le moment. ». Aucun compte SHALL être créé et aucun e-mail envoyé. Les boutons « Créer un compte » SHALL rester affichés.

#### Scenario: Ouverture de la page d'inscription
- **WHEN** un visiteur ouvre la page d'inscription, directement ou par un bouton « Créer un compte », alors que les inscriptions sont fermées
- **THEN** il est ramené à l'accueil et un toast d'avertissement indique que les inscriptions sont fermées

#### Scenario: Envoi du formulaire
- **WHEN** un visiteur envoie un formulaire d'inscription valide alors que les inscriptions viennent d'être fermées
- **THEN** aucun compte n'est créé, aucun e-mail n'est envoyé, et il est ramené à l'accueil avec le même toast d'avertissement

#### Scenario: Boutons toujours visibles
- **WHEN** un visiteur consulte l'accueil, la page de connexion ou l'en-tête alors que les inscriptions sont fermées
- **THEN** le bouton « Créer un compte » reste affiché

#### Scenario: Aucun manager
- **WHEN** un visiteur s'inscrit alors que les inscriptions sont fermées mais qu'aucun manager n'existe
- **THEN** l'inscription aboutit normalement et le compte créé a le rôle `admin`

#### Scenario: Comptes existants
- **WHEN** les inscriptions sont fermées
- **THEN** l'activation d'un compte par lien, le renvoi de l'e-mail d'activation, la connexion et la réinitialisation du mot de passe continuent de fonctionner

## MODIFIED Requirements

### Requirement: Inscription d'un manager
Le système SHALL permettre à un visiteur de créer un compte manager avec un nom, un e-mail unique et un mot de passe, tant que les inscriptions sont ouvertes. Le compte créé SHALL être inactif tant que l'adresse e-mail n'a pas été validée, et l'inscription SHALL NOT ouvrir de session.

#### Scenario: Inscription valide
- **WHEN** un visiteur soumet un nom, un e-mail inconnu et un mot de passe valide
- **THEN** un compte inactif est créé, un e-mail d'activation est envoyé à cette adresse, le visiteur n'est pas connecté et il est redirigé vers la page de connexion avec un message l'invitant à consulter sa boîte mail

#### Scenario: E-mail déjà utilisé
- **WHEN** un visiteur soumet un e-mail déjà associé à un compte
- **THEN** aucun compte n'est créé, aucun e-mail n'est envoyé et une erreur est affichée
