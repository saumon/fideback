# Design

## Context

L'espace `/admin` est un namespace de routes dont les contrôleurs héritent d'`Admin::BaseController` : l'authentification vient d'`ApplicationController`, puis `require_admin!` rend la page introuvable (404) à tout manager non Admin. Les « utilisateurs » sont les enregistrements `Manager` (Devise `confirmable` : `confirmed_at` est nul tant que le compte n'est pas activé). Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Réutiliser la garde existante, sans seconde implémentation du contrôle d'accès.
- Un écran cohérent avec le style visuel de l'application (coloré, animé, `prefers-reduced-motion` respecté).

**Non-Goals:**
- Pagination, recherche, filtres, actions sur les comptes.
- Nouvelle colonne ou migration.

## Decisions

- **Route et contrôleur** : `resources :users, only: :index` dans `namespace :admin`, servi par `Admin::UsersController#index`. Le nom « users » suit l'intitulé de l'écran et l'URL choisie, même si le modèle s'appelle `Manager`. Alternative écartée : `admin/managers`, plus fidèle au modèle mais qui ne correspond pas au vocabulaire « Utilisateurs » de l'interface.
- **Requête** : `Manager.order(created_at: :desc, id: :desc)`. L'`id` départage les inscriptions simultanées pour un ordre stable. Pas de pagination : le volume de comptes reste faible, et la liste complète est ce qui a été demandé.
- **Statut de confirmation** : badge « Non confirmé » affiché quand `confirmed_at` est nul, en réutilisant la classe `.status` existante (variante dédiée pour la couleur). Alternative écartée : `confirmed?` de Devise, équivalent mais qui masque la colonne lue ; on garde la lecture directe via un prédicat Devise (`confirmed?`) dans la vue, sans logique en plus.
- **Vue** : tableau dans `.table-scroll` (déjà présent pour le défilement horizontal sur mobile), titre dans `.page-head`, lien « Retour à l'administration » ; textes en dur en français, rôle affiché via un libellé « Admin » / « Manager ». La date d'inscription est formatée avec `l(..., format: :long)` ou le format de date déjà utilisé ailleurs dans les vues.
- **Bouton sur `/admin`** : un `link_to "Utilisateurs", admin_users_path, class: "btn btn-primary"` remplace le message « Rien à administrer ». Le test existant qui interdit `form, button, input` reste valable, puisque le bouton est un lien.

## Risks / Trade-offs

- [Liste non paginée, lourde si le nombre de comptes explose] → hors périmètre ; ajouter la pagination quand le besoin apparaît.
- [E-mails des utilisateurs exposés] → écran réservé à l'Admin, 404 pour tout autre manager ; couvert par des tests d'accès.
- [Le test existant « sans action » du tableau de bord devra évoluer pour exiger le lien] → le mettre à jour dans la même tâche que la vue.
