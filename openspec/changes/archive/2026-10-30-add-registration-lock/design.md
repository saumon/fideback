# Design

## Context

L'inscription passe par `Managers::RegistrationsController`, qui hérite de Devise et ne personnalise que la redirection après inscription. Devise y pose déjà `require_no_authentication` (un manager connecté qui ouvre l'inscription est renvoyé ailleurs). Les liens « Créer un compte » sont à trois endroits : l'accueil, l'en-tête (et le tiroir mobile) et le lien Devise de la page de connexion. Le site n'a aucun réglage global : il n'existe pas de table de paramètres. Le toast de l'application ne retient que `notice` et `alert` du flash (`_toasts.html.erb`), `toasts_controller.js` temporise tout toast qui n'est pas une alerte, et `Admin::BaseController` garde l'espace d'administration (404 pour un non-Admin). Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Un réglage persistant, modifiable seulement par l'Admin, appliqué à `new` et `create` de l'inscription.
- Réutiliser la garde, le toast, la navigation et les conventions de l'espace d'administration.

**Non-Goals:**
- Un système de réglages riche (types, validation, historique) : une seule clé suffit aujourd'hui.
- Toucher à la connexion, à l'activation, au renvoi d'e-mail ou à la réinitialisation du mot de passe.

## Decisions

- **Table `settings` clé/valeur.** Colonnes `key` (unique, non nulle) et `value` (chaîne). Le modèle `Setting` expose `Setting.registrations_open?` (vrai si la clé est absente, donc ouvert par défaut) et `Setting.registrations_open = bool` (écrit ou met à jour la ligne). Alternatives écartées : une colonne booléenne sur une table à ligne unique (une migration par futur réglage), un fichier ou une variable d'environnement (l'Admin ne pourrait pas le changer depuis l'écran), `Rails.cache` (pas durable, peut être vidé).
- **Garde dans le contrôleur d'inscription.** `before_action :require_open_registrations, only: %i[new create]` dans `Managers::RegistrationsController`, déclaré avec `before_action` simple pour s'exécuter après `require_no_authentication` : un manager connecté garde le comportement de Devise. Règle : on laisse passer si `Setting.registrations_open? || Manager.none?`. Sinon `redirect_to root_path, flash: { warning: "Les inscriptions sont fermées pour le moment." }, status: :see_other` (le 303 convient aussi au `POST` de Turbo). Le contrôle de `create` couvre le formulaire resté ouvert dans un onglet. La condition `Manager.none?` n'est pas atomique avec l'insertion, mais un faux positif ne laisse passer qu'une inscription de plus quand le site est vide ; le `before_create` existant garantit déjà un seul premier Admin.
- **Les liens ne bougent pas.** Les trois « Créer un compte » restent tels quels : c'est la garde qui répond, pas la vue. Il n'y a donc ni test de vue conditionnel ni risque d'oublier un lien.
- **Écran `/admin/danger-zone`.** `namespace :admin { resource :danger_zone, path: "danger-zone", only: %i[show update] }`, servi par `Admin::DangerZoneController < Admin::BaseController` (404 pour un non-Admin, redirection vers la connexion pour un anonyme, déjà gérés). Le nom de l'URL suit l'intitulé « Danger zone ». `update` reçoit `registrations_open` (`true` ou `false`), l'enregistre et redirige vers l'écran avec une notice.
- **Confirmation côté serveur, sans JavaScript.** « Désactiver les inscriptions » est un lien vers `danger_zone_path(confirm: 1)`, qui affiche dans la page la carte de confirmation (rappel que les comptes existants ne changent pas) avec un bouton qui envoie le `PATCH` et un lien « Annuler » vers l'écran. Alternatives écartées : `turbo_confirm` (boîte du navigateur, hors du style du site), un contrôleur Stimulus (du code pour une confirmation qui marche déjà en HTML). « Réactiver » est un bouton direct : l'action est sans risque.
- **Toast d'avertissement.** `_toasts.html.erb` retient aussi `warning`, avec la classe `flash-warning` et le même rôle que la notice (`aria-live="polite"`, pas de `role="alert"`). `toasts_controller.js` temporise déjà tout toast hors alerte : il suffit d'allonger sa durée (`+ 2000 ms` pour un avertissement, dans la même borne maximale élargie). `application.css` ajoute `.toast.flash-warning { --toast-color: var(--saffron); }`. Pour l'empilement, un avertissement est retirable comme une notice ; seule l'alerte est protégée.
- **Style de la zone.** Carte à bordure rouge en pointillés sur fond rouge très léger, libellé « Réservé à l'administrateur », pastille d'état « Ouvertes » (jade) ou « Fermées » (encre), conformément à la maquette validée. Le bouton « Danger zone » de `/admin` reprend le style `.btn-danger` existant.

## Risks / Trade-offs

- [L'Admin se ferme la porte : rien n'empêche de désactiver puis d'oublier] → l'état est affiché en clair, la réactivation est à un clic, et le cas du site vide reste ouvert.
- [Un toast d'avertissement plus long couvre davantage l'écran] → il reste fermable, survolable, et limité par l'empilement.
- [Le premier réglage global fait naître une table pour une seule clé] → la structure clé/valeur reste minimale, sans typage, tant qu'il n'y a pas d'autre réglage.
- [Un refus à l'envoi d'un formulaire rempli perd la saisie du visiteur] → acceptable : le visiteur est prévenu et il n'y avait plus de compte à créer.
