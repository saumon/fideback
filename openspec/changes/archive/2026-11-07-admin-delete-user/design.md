# Design

## Context

L'écran `admin/users` n'a qu'une action `index` (`Admin::UsersController`). Le garde `Admin::BaseController#require_admin!` renvoie déjà le 404 aux non-Admins ; `authenticate_manager!` redirige les anonymes. Le modèle `Manager` porte déjà la cascade voulue : `campaigns` et `contacts` en `dependent: :destroy`, `login_links` en `delete_all` (et `on_delete: :cascade` en base), `invitations.invited_by_id` en `on_delete: :nullify`. `Campaign#deletable?` (refus de supprimer une campagne en cours) est vérifié par le contrôleur de campagnes et non par un callback, précisément pour que la suppression d'un compte la traverse. Le dialogue `turbo_confirm` (`turbo_confirm_detail`, `turbo_confirm_tone: "danger"`, `turbo_confirm_icon: "trash"`) est déjà utilisé pour « Annuler » une invitation et pour supprimer une campagne.

## Goals / Non-Goals

**Goals:**
- Supprimer un manager depuis `admin/users` en réutilisant la cascade du modèle, sans nouvelle colonne ni migration.
- Appliquer la règle d'auto-suppression côté serveur.

**Non-Goals:**
- Désactivation réversible d'un compte, changement de rôle, e-mail au manager supprimé.
- Page de confirmation dédiée sans JavaScript (voir Risques).

## Decisions

**Route et action.** `resources :users, only: %i[index destroy]` dans `namespace :admin`, et `Admin::UsersController#destroy`. Pas de nouveau contrôleur : l'écran et ses actions restent ensemble. Le garde Admin est hérité.

**Cible retrouvée par `Manager.find`.** Un manager déjà supprimé lève `RecordNotFound`, rendu en 404 par Rails comme pour toute adresse inexistante, ce qui satisfait l'exigence « Manager déjà supprimé » sans code propre.

**Auto-suppression : refus avant toute recherche d'effet.** `destroy` compare la cible à `current_manager` ; en cas d'égalité, `redirect_to admin_users_path, alert: "Vous ne pouvez pas supprimer votre propre compte.", status: :see_other`, sans rien détruire. La redirection avec alerte suit le modèle de `CampaignsController#destroy` (et les alertes sont rendues par le système de notifications existant). Alternative écartée : un 422 sans corps, adapté aux requêtes forgées mais muet pour un humain qui aurait un onglet périmé. Le bouton masqué dans la vue (`manager == current_manager`) n'est qu'un confort.

**Cascade : celle du modèle, dans une transaction.** `manager.destroy` suffit : `destroy` enveloppe déjà les dépendances dans une transaction, donc un échec à mi-chemin n'efface rien. Les campagnes en cours sont supprimées aussi (`deletable?` n'est pas consulté), conformément à la décision de l'Admin. Alternative écartée : refuser tant que le manager a des campagnes, qui obligerait l'Admin à les supprimer, ce qu'il ne peut pas faire (elles ne sont pas les siennes).

**Confirmation chiffrée.** Un helper (dans le style de `delete_campaign_detail`) compose le détail du dialogue : « Ses N campagne(s) et toutes les réponses recueillies seront effacées. Cette action est définitive. », ou « Aucune campagne ne sera perdue. » à zéro. Le nombre est lu à l'affichage de la liste ; pour éviter un N+1, charger les nombres de campagnes en une requête (`Manager.left_joins(:campaigns).group(...).count` ou `counter`/`select` agrégé) plutôt que `manager.campaigns.count` par ligne. Alternative écartée : un compteur en cache sur `managers`, une migration pour un simple affichage.

**Session invalidée sans code.** Devise désérialise la session et le cookie « se souvenir de moi » en cherchant le manager en base ; une fois supprimé, `current_manager` est `nil` et `authenticate_manager!` redirige vers la connexion. La seule exigence est un test qui le prouve, avec une session ouverte avant la suppression.

**Notice.** `redirect_to admin_users_path, notice: "#{name} a été supprimé.", status: :see_other` (303, comme les autres suppressions, pour que Turbo suive le `DELETE`).

**Aucun e-mail.** Pas de mailer ; rien à ajouter.

## Risks / Trade-offs

- [Perte irréversible de données, y compris des réponses de sondés] → confirmation chiffrée et ton danger ; pas de sauvegarde ni de corbeille dans ce changement.
- [Sans JavaScript, `turbo_confirm` ne s'affiche pas et le bouton supprime directement] → aligné sur « Annuler » et la suppression de campagne qui ont la même limite ; si on veut la parité avec la Danger zone (confirmation rendue par le serveur), c'est un changement distinct.
- [Sondés dont la campagne disparaît : leur lien personnel mène à une page introuvable] → comportement déjà celui de la suppression d'une campagne ; aucun message particulier.
- [Aucun Admin ne peut être supprimé puisque l'Admin est seul et ne peut pas se supprimer] → conséquence voulue ; une future gestion des rôles devra revoir la règle.
- [Suppression concurrente de deux managers, ou double clic] → second appel en 404, sans effet.
