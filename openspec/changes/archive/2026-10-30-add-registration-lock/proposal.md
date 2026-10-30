# Proposal

## Why

Aujourd'hui, n'importe quel visiteur peut créer un compte manager. L'Admin n'a aucun moyen de fermer le site à de nouvelles inscriptions une fois ses utilisateurs en place. Un interrupteur dans l'espace d'administration lui donne ce contrôle, sans intervention technique.

## What Changes

- Nouvel écran **« Danger zone »** (`/admin/danger-zone`), réservé à l'Admin, atteint par un nouveau bouton « Danger zone » sur l'écran d'administration. Il affiche l'état des inscriptions (ouvertes ou fermées) et permet de les désactiver, après confirmation, puis de les réactiver.
- Quand les inscriptions sont fermées, le bouton « Créer un compte » **reste visible** partout (accueil, en-tête, tiroir mobile, page de connexion). Un clic dessus, comme l'ouverture directe de `/managers/sign_up` ou l'envoi du formulaire, affiche un **toast d'avertissement** « Les inscriptions sont fermées pour le moment. » et ramène à l'accueil. Aucun compte n'est créé.
- Tant qu'**aucun manager n'existe**, l'inscription reste possible quel que soit le réglage, pour que le premier compte puisse devenir Admin.
- Les comptes déjà inscrits ne changent pas : activation par lien, renvoi de l'e-mail d'activation, connexion et réinitialisation du mot de passe restent disponibles.
- Nouveau type de toast, l'**avertissement**, en safran : il disparaît de lui-même, après un délai plus long qu'une notice, avec le même minuteur visuel.
- Premier réglage global du site : un réglage « inscriptions ouvertes » conservé en base, ouvert par défaut.

Hors périmètre : liste blanche de domaines ou d'e-mails, invitations, désactivation ou suppression de comptes, autres réglages du site.

## Capabilities

### New Capabilities
- `admin-danger-zone`: écran réservé à l'Admin qui affiche et change le réglage d'ouverture des inscriptions, et conservation de ce réglage.

### Modified Capabilities
- `admin-area`: l'écran d'administration porte un second bouton, « Danger zone ».
- `manager-auth`: l'inscription est refusée, avec avertissement et retour à l'accueil, quand les inscriptions sont fermées ; exception tant qu'aucun manager n'existe.
- `ui-notifications`: ajout du toast d'avertissement.

## Impact

- Base : nouvelle table `settings` (migration).
- Code : modèle `Setting`, `Admin::DangerZoneController` et sa vue, `Managers::RegistrationsController` (garde sur `new` et `create`), `app/views/admin/dashboard/show.html.erb` (bouton), `config/routes.rb`, `app/views/layouts/_toasts.html.erb` et `toasts_controller.js` (type avertissement), `application.css` (couleur safran, zone de danger).
- Tests : intégration (accès Admin, refus GET et POST, exception sans manager, comptes existants inchangés, balisage du toast), modèle `Setting`, test système du toast.
- README : fonctionnement du réglage.
