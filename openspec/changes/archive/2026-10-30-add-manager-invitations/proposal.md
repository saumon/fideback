# Proposal

## Why

Quand les inscriptions sont fermées, l'Admin n'a aucun moyen d'accueillir une personne précise : il doit rouvrir les inscriptions à tout le monde. Une invitation nominative permet d'ouvrir le site à une personne choisie, avec un lien qu'elle seule peut utiliser, sans rien changer au réglage des inscriptions.

## What Changes

- Un bouton **« Inviter un manager »** sur l'écran des utilisateurs (`/admin/users`) ouvre un formulaire nom + e-mail, réservé à l'Admin. Il fonctionne que les inscriptions soient ouvertes ou fermées.
- L'invité reçoit un **e-mail d'invitation** (habillage commun, version texte, salutation par le nom) avec un lien d'acceptation valable **7 jours**.
- Le lien ouvre une **page d'acceptation** : nom pré-rempli et modifiable, e-mail verrouillé, choix du mot de passe. Le compte est créé **déjà activé** (le clic sur le lien prouve la boîte mail), avec le rôle `manager`, puis l'invité est renvoyé vers la connexion. Il n'est pas connecté d'office.
- Un bloc **« Invitations en attente »** sur l'écran des utilisateurs liste les invitations non acceptées, en attente ou expirées, avec « Renvoyer » (nouveau lien, validité repartant de zéro, nouvel e-mail) et « Annuler ».
- Une adresse qui a déjà un compte ne peut pas être invitée ; réinviter une adresse déjà invitée remplace l'invitation précédente et invalide son lien.
- Un lien invalide, expiré, annulé ou déjà utilisé mène à une page explicative qui renvoie vers l'administrateur.
- L'écran des utilisateurs n'est plus « sans action » : ses seules actions portent sur les invitations, jamais sur les comptes existants.

Hors périmètre : choix du rôle de l'invité (toujours `manager`), invitation en lot, durée de validité réglable, relance automatique, suppression de comptes.

## Capabilities

### New Capabilities
- `manager-invitations`: invitation nominative d'un manager par l'Admin, e-mail, acceptation, expiration et suivi.

### Modified Capabilities
- `admin-users`: l'écran porte le bouton « Inviter un manager » et le suivi des invitations ; il reste sans action sur les comptes existants.
- `manager-auth`: l'acceptation d'une invitation reste possible quand les inscriptions sont fermées.

## Impact

- Base : nouvelle table `invitations` (migration).
- Code : modèle `Invitation`, `Admin::InvitationsController` (formulaire, création, renvoi, annulation), contrôleur public d'acceptation, `InvitationMailer` et ses vues (HTML et texte), `Admin::UsersController` et sa vue, routes, styles, traductions du modèle.
- Tests : modèle, mailer, intégration (accès, création, erreurs, renvoi, annulation, acceptation, liens invalides), test système du parcours.
- README : fonctionnement des invitations.
