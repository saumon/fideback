## Why

L'Admin peut inviter des managers mais pas retirer un compte : un compte créé par erreur, abandonné ou indésirable reste indéfiniment sur le site. L'écran « Utilisateurs » doit lui permettre de supprimer un manager, sans pouvoir se supprimer lui-même.

## What Changes

- Chaque ligne de la liste des managers de l'écran « Utilisateurs » (`admin/users`) propose une action « Supprimer », soumise à une confirmation (dialogue `turbo_confirm`, ton danger) qui annonce que les campagnes du manager et toutes les réponses recueillies seront effacées, avec le nombre de campagnes.
- La suppression efface le manager et, en cascade, ses campagnes (questions, sondés, réponses), ses contacts et ses liens de connexion ; les invitations qu'il a envoyées sont conservées, leur auteur étant mis à vide.
- Un manager non confirmé se supprime comme les autres.
- L'Admin connecté ne peut pas supprimer son propre compte : sa ligne n'a pas d'action « Supprimer » et le serveur refuse toute requête de suppression visant son compte, sans rien supprimer.
- La session ouverte du manager supprimé cesse d'être valable (y compris le cookie « se souvenir de moi »).
- Le manager supprimé n'est pas prévenu par e-mail.
- **BREAKING** (côté spec) : l'écran n'est plus « en lecture seule » ; l'exigence correspondante de `admin-users` et le Purpose de la capacité sont modifiés.

## Capabilities

### New Capabilities

Aucune.

### Modified Capabilities

- `admin-users` : l'exigence « Écran en lecture seule » est remplacée par une exigence d'actions limitées (invitations et suppression), et de nouvelles exigences décrivent la suppression avec confirmation, l'interdiction de se supprimer soi-même, la cascade et l'invalidation de la session.

## Impact

- `config/routes.rb` : `resources :users, only: %i[index destroy]` dans l'espace `admin`.
- `app/controllers/admin/users_controller.rb` : action `destroy`, refus si la cible est le manager connecté.
- `app/views/admin/users/index.html.erb` : bouton « Supprimer » par ligne, absent sur la ligne de l'Admin connecté.
- `app/models/manager.rb` : aucune relation à ajouter (`campaigns` et `contacts` sont déjà `dependent: :destroy`, `login_links` en cascade en base, `invitations.invited_by_id` en `nullify`).
- Tests : intégration, helper et système (suppression, auto-suppression refusée, accès non-Admin, session invalidée).
- Hors périmètre : désactivation réversible d'un compte, changement de rôle, notification par e-mail.
