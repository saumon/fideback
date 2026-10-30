# Spec Delta

## MODIFIED Requirements

### Requirement: Inscriptions fermées par l'Admin
Lorsque l'Admin a fermé les inscriptions et qu'au moins un manager existe, le système SHALL refuser toute inscription par la page d'inscription : son ouverture comme l'envoi de son formulaire ramènent le visiteur à l'accueil avec un toast d'avertissement « Les inscriptions sont fermées pour le moment. ». Aucun compte SHALL être créé et aucun e-mail envoyé. Les boutons « Créer un compte » SHALL rester affichés.

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

#### Scenario: Invitation acceptée
- **WHEN** une personne invitée par l'Admin accepte son invitation alors que les inscriptions sont fermées
- **THEN** son compte est créé normalement
