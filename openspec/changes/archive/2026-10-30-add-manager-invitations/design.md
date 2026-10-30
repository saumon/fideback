# Design

## Context

Un compte manager se crée par l'inscription Devise (`confirmable` : inactif jusqu'au clic sur un e-mail, lien valable 24 h). Les sondés reçoivent déjà une invitation par e-mail : `RespondentMailer#invitation`, jeton `has_secure_token` de 36 caractères, envoi `deliver_later`, vues HTML et texte dans l'habillage commun (`mailer.html.erb`). `Admin::BaseController` garde l'espace d'administration (404 pour un non-Admin) et `Admin::UsersController` liste les managers. La garde d'inscription fermée (`require_open_registrations`) ne porte que sur `new` et `create` de `Managers::RegistrationsController`. Les textes sont écrits en dur en français, les messages de validation passent par `config/locales`. Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Une invitation est un objet à part : elle n'apparaît pas dans la liste des managers avant d'être acceptée.
- Réutiliser le jeton, l'envoi, l'habillage et la garde d'administration existants.

**Non-Goals:**
- Passer par le contrôleur d'inscription de Devise : l'acceptation a ses propres règles (adresse imposée, compte activé, pas de garde de fermeture).
- Une gem d'invitation ou un moteur de relances.

## Decisions

- **Table `invitations`.** Colonnes `name`, `email`, `token` (unique), `expires_at`, `accepted_at` (nul tant que l'invitation n'est pas acceptée), `invited_by_id` (référence nulle vers `managers`, `ON DELETE SET NULL`) et les horodatages. Un index unique **partiel** sur `email` là où `accepted_at IS NULL` garantit une seule invitation non acceptée par adresse, y compris sous concurrence ; SQLite le gère. Une invitation acceptée reste en base, avec sa date, pour l'historique. Alternatives écartées : créer le manager tout de suite avec un mot de passe aléatoire (comptes fantômes dans la liste, couplage avec `confirmable`), réutiliser le jeton de réinitialisation du mot de passe (mécanisme détourné).
- **Modèle `Invitation`.**
  - `has_secure_token :token, length: 36` ; `normalizes :email` (suppression des espaces, minuscules), comme `Respondent`.
  - Validations : nom présent, e-mail présent et de forme valide, et refus d'une adresse déjà portée par un `Manager` (sans tenir compte de la casse ni de l'activation). Cette dernière est une validation du modèle, rejouée à l'acceptation.
  - États : `accepted?` (`accepted_at`), `expired?` (`expires_at` dans le passé), `pending?` (ni l'un ni l'autre) ; portée `unaccepted`. `VALIDITY = 7.days`.
  - `Invitation.invite!(name:, email:, by:)` retrouve l'invitation non acceptée de cette adresse ou en construit une, met à jour le nom, régénère le jeton, repousse l'expiration et envoie l'e-mail : le remplacement par réinvitation et le **renvoi** sont donc la même opération (`#renew!(by:)`), qui invalide l'ancien lien par la régénération du jeton.
  - L'envoi suit `Respondent#invite!` : dans une transaction, puis `deliver_later`.
- **Acceptation sans passer par Devise.** `Invitation#accept(name:, password:, password_confirmation:)` construit un `Manager` avec l'adresse de l'invitation, appelle `skip_confirmation!` (le compte est activé et aucun e-mail d'activation ne part), l'enregistre et marque l'invitation acceptée, dans une transaction. Le rôle est celui par défaut (`manager`), la règle existante du premier compte restant inchangée. Si l'enregistrement du manager échoue sur l'adresse (devenue inscrite entre-temps), l'invitation est traitée comme invalide ; s'il échoue sur le mot de passe, la page est réaffichée avec les erreurs.
- **Contrôleur public d'acceptation.** `GET /invitations/:token` et `PATCH /invitations/:token` (`InvitationAcceptancesController`), sans authentification requise, dans la mise en page habituelle. Si aucune invitation en attente ne correspond (inconnu, expiré, annulé, remplacé, accepté, adresse déjà inscrite), il rend la page d'invitation invalide avec le statut 404 : une seule page et un seul message, sans distinguer les cas. Un manager déjà connecté est renvoyé vers ses campagnes avec une alerte, comme Devise le fait pour l'inscription. L'acceptation réussie redirige en 303 vers la connexion avec une notice, sans ouvrir de session.
- **Contrôleur d'administration.** `Admin::InvitationsController < Admin::BaseController` : `new`, `create` (réaffiche le formulaire en 422 si invalide), `destroy` (annulation) et `resend` (route membre `POST`), avec les redirections et notices vers `/admin/users`. La garde 404 pour un non-Admin et la redirection d'un anonyme sont héritées. Routes : `namespace :admin { resources :invitations, only: %i[new create destroy] { post :resend, on: :member } }`.
- **Suivi sur l'écran des utilisateurs.** `Admin::UsersController#index` charge aussi `Invitation.unaccepted` triée par date de création décroissante, et la vue affiche le bloc « Invitations en attente » dans un `.table-scroll`, avec la pastille d'état et les actions. « Renvoyer » est un `button_to` en `POST` et « Annuler » un `button_to` en `DELETE`, avec une confirmation `turbo_confirm` comme « Renvoyer » pour les sondés. Le bouton « Inviter un manager » prend place dans l'en-tête de la page.
- **E-mail.** `InvitationMailer#invitation(invitation)` : sujet « <invitant> vous invite à rejoindre Fideback », vues HTML et texte, bouton « Accepter l'invitation » au style commun, adresse du lien en clair dans la version texte, date limite en toutes lettres. L'invitant est l'Admin qui a envoyé ou renvoyé en dernier (`invited_by`). Le lien est construit avec l'hôte public existant (`APP_HOST`).
- **Un seul lien invalide pour tous les cas.** Distinguer « expiré » de « inconnu » n'apporterait rien à l'invité, qui doit de toute façon demander une nouvelle invitation, et révélerait si un jeton a existé.
- **Style.** Formulaire et page d'acceptation sur le modèle des pages Devise (`main` étroit, carte), bloc de suivi en tableau comme la liste des managers, pastilles `.status` (« En attente » réutilise `status-pending`, « Expirée » reçoit une variante safran), conformément à la maquette validée.

## Risks / Trade-offs

- [Un jeton valable 7 jours circule par e-mail] → il est long (36 caractères), à usage unique, lié à une adresse, invalidé par tout renvoi, annulation ou acceptation.
- [Un renvoi par un autre Admin change l'invitant affiché] → l'e-mail suivant nomme celui qui renvoie ; acceptable, il n'y a qu'un Admin en pratique.
- [Plus aucun manager n'existe à l'acceptation (l'invitant a supprimé son compte)] → la règle existante du premier compte s'applique et l'invité devient Admin, ce qui est cohérent avec elle.
- [Le Purpose de la spec `admin-users` dit « lecture seule »] → à réécrire à la main dans la spec principale à l'archivage, un delta ne pouvant pas le modifier.
- [Une invitation expirée jamais traitée reste listée] → elle porte l'état « Expirée » et peut être renvoyée ou annulée ; pas de purge automatique.
