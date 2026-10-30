# Spec Delta

## MODIFIED Requirements

### Requirement: Renvoi de l'e-mail d'activation
Le système SHALL permettre de demander un nouvel e-mail d'activation depuis une page dédiée, avec une réponse identique quelle que soit l'adresse saisie, et au plus un e-mail par adresse toutes les 5 minutes. Chaque nouvel e-mail SHALL invalider les liens d'activation précédents.

#### Scenario: Renvoi pour un compte inactif
- **WHEN** un visiteur saisit l'e-mail d'un compte inactif dont le dernier e-mail d'activation date de plus de 5 minutes
- **THEN** un nouvel e-mail d'activation est envoyé et les liens des e-mails précédents cessent de fonctionner

#### Scenario: Demandes rapprochées
- **WHEN** un visiteur redemande un e-mail d'activation pour une adresse moins de 5 minutes après le dernier envoi
- **THEN** aucun e-mail n'est envoyé

#### Scenario: Adresse inconnue ou compte déjà actif
- **WHEN** un visiteur saisit une adresse sans compte, ou celle d'un compte déjà activé
- **THEN** aucun e-mail n'est envoyé

#### Scenario: Réponse indistinguable
- **WHEN** un visiteur demande un e-mail d'activation, que l'adresse soit inconnue, active, inactive ou limitée par le délai de 5 minutes
- **THEN** la page et le message affichés sont identiques dans tous les cas

#### Scenario: Lien de retour à la connexion
- **WHEN** un visiteur ouvre la page de demande d'un nouvel e-mail d'activation, sur ordinateur ou sur un écran de téléphone
- **THEN** le lien « Retour à la connexion » mène à la page de connexion, et il est séparé de la carte du formulaire et écrit à la même taille que les liens de la page de mot de passe oublié
