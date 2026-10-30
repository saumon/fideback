# Proposal

## Why

L'Admin n'a aujourd'hui aucun moyen de voir qui s'est inscrit sur le site : l'écran d'administration est vide. Lister les comptes est la première action d'administration utile, et elle donne à l'Admin de la visibilité sur les inscriptions restées bloquées avant l'activation.

## What Changes

- Nouvel écran « Utilisateurs » (`/admin/users`), en lecture seule, réservé à l'Admin, qui liste les managers inscrits.
- Chaque ligne affiche le nom, l'e-mail, le rôle (Manager ou Admin) et la date d'inscription ; les comptes non confirmés portent un badge « Non confirmé ».
- Liste triée par date d'inscription décroissante, sans pagination ni recherche.
- Un bouton « Utilisateurs » est ajouté à l'écran d'administration, et l'écran des utilisateurs offre un lien de retour vers « Administration ».
- L'écran d'administration cesse d'être « sans action » : il porte désormais ce bouton (toujours aucun formulaire).

Hors périmètre : suppression de compte, changement de rôle, pagination, recherche, statistiques par manager (nombre de campagnes).

## Capabilities

### New Capabilities
- `admin-users`: liste en lecture seule, réservée à l'Admin, des managers inscrits (colonnes, statut de confirmation, tri).

### Modified Capabilities
- `admin-area`: l'exigence « Écran d'administration sans action » évolue, l'écran propose maintenant un bouton « Utilisateurs ».

## Impact

- Routes : `admin/users` dans le namespace `admin`.
- Code : nouveau `Admin::UsersController` (hérite d'`Admin::BaseController`, donc même garde 404), nouvelle vue, modification de `app/views/admin/dashboard/show.html.erb`, styles associés.
- Pas de migration ni de nouvelle dépendance.
- Tests : contrôleur/intégration (accès Admin, manager, anonyme) et contenu de la liste.
