# Proposal

## Why

Fideback n'a aujourd'hui qu'une seule sorte de compte : le manager. Il n'existe aucun moyen de distinguer la personne qui administre le site des autres, ni d'y réserver des écrans. Poser un rôle Admin et un espace d'administration prépare les futures actions d'administration.

## What Changes

- Les managers reçoivent un rôle : `manager` (par défaut) ou `admin`.
- Le compte créé alors que la table des managers est vide reçoit le rôle `admin` dès l'inscription, activé ou non. Si cet Admin supprime son compte, personne ne le remplace.
- La migration promeut en `admin` le manager le plus ancien déjà en base (et ne fait rien si la base est vide).
- Un espace d'administration est accessible sur `/admin`, réservé aux Admins ; un manager non Admin reçoit une réponse 404.
- La barre de navigation affiche un lien « Administration » aux seuls Admins. Il mène à un écran qui ne contient pour l'instant aucune action.

## Capabilities

### New Capabilities
- `admin-area`: le rôle Admin, la garde d'accès à l'espace d'administration, son lien de menu et son écran d'accueil sans action.

### Modified Capabilities
- `manager-auth`: l'inscription attribue le rôle `admin` au tout premier compte créé, et la reprise des comptes existants promeut le plus ancien.

## Impact

- `db/migrate` : nouvelle colonne `managers.role` et promotion du plus ancien manager ; `db/schema.rb`.
- `app/models/manager.rb` : rôle et attribution à la création.
- `config/routes.rb`, nouveau contrôleur `Admin::` et sa vue.
- `app/views/layouts/application.html.erb` : lien de menu conditionnel.
- Tests : modèle, intégration (accès, menu, inscription) et migration.
- Aucune dépendance nouvelle.
