# Proposal

## Why

Sur la page « Activer mon compte » (`/managers/confirmation/new`), le lien « Retour à la connexion » est mal présenté :
- il est collé sous la carte du formulaire et chevauche son ombre violette ;
- sa police est plus grosse que celle des liens des autres écrans de compte.

Sur la page « Mot de passe oublié ? » (`/managers/password/new`), les liens sont regroupés sous la carte, séparés d'elle par un espace net, et écrits plus petit. Le lien est écrit directement dans la vue, en dehors du bloc de liens que partagent les autres écrans de compte.

## What Changes

- Le lien « Retour à la connexion » de la page « Activer mon compte » prend la présentation des liens de la page « Mot de passe oublié ? » : même espacement sous la carte et même taille de police.
- Le libellé du lien et sa destination, la page de connexion, ne changent pas.
- La même vue sert aussi après un lien d'activation invalide (expiré, déjà utilisé ou inconnu). Le lien y prend la même présentation.

Hypothèse retenue : seule la présentation change. La page garde son unique lien « Retour à la connexion ». Elle n'affiche pas la liste complète de la page « Mot de passe oublié ? » (Connexion, Inscription, etc.).

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities
- `manager-auth` : l'exigence « Renvoi de l'e-mail d'activation » gagne un scénario. Le lien de retour à la connexion doit être détaché de la carte du formulaire et présenté comme les liens des autres écrans de compte.

## Impact

- Vue : `app/views/devise/confirmations/new.html.erb`.
- Tests : `test/integration/manager_confirmation_test.rb`.
- Aucun changement de CSS : la classe `.auth-links` existe déjà. Aucun changement de route, de traduction ni de dépendance.
