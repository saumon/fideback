# Design

## Context

Fideback utilise déjà Devise (`database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`) pour le modèle `Manager`, sans `:confirmable`. `config.reconfirmable = true` est déjà positionné dans `devise.rb` mais sans effet. Les e-mails existants (invitation de sondé, mot de passe oublié) passent par `ApplicationMailer`, dont l'expéditeur est codé en dur, comme celui de `devise.rb`. Hors développement, rien ne configure `delivery_method`/`smtp_settings` ; `default_url_options` est écrit en ligne par environnement et n'accepte que `APP_HOST`. Modèle de référence : `saumon/lockswap` (spec 034). Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Réutiliser les mécanismes de Devise : un seul chemin pour l'activation et la reconfirmation d'adresse.
- Que le système ne permette pas d'apprendre quelle adresse a un compte (même principe que le reset de mot de passe).
- Que les réglages mail se changent par déploiement (ENV ou credentials), sans toucher au code.

**Non-Goals:**
- Activation manuelle par un administrateur (`confirmed_by`), journaux `account_mail`, mailer dédié à la reconfirmation, `:lockable`.
- Personnalisation graphique poussée de l'e-mail : texte sobre, dans le style des e-mails existants.

## Decisions

**1. `:confirmable` de Devise, `allow_unconfirmed_access_for` à 0.** Le compte est inactif jusqu'au clic. Alternative : accès provisoire pendant N jours, écarté car le spec exige un refus de connexion. `confirm_within = 24.hours` comme lockswap.

**2. Contrôleur `Managers::ConfirmationsController < Devise::ConfirmationsController`**, avec `create` et `show` surchargés (route via `devise_for :managers, controllers: { confirmations: ..., registrations: ... }`).
- `create` : réponse identique dans tous les cas (inconnu, actif, limité, envoyé) ; redirection vers la connexion avec le message « paranoid » de Devise. Cooldown 5 min sur `confirmation_sent_at`.
- `show` : `confirm_by_token`, succès → connexion avec notice, sans connecter ; échec → rend la page de renvoi avec un résultat `:expired`, `:already_active` ou `:unrecognised`, déduit de `errors.details[:email]`.
- Alternative : conserver le contrôleur Devise tel quel. Écartée : il révèle l'existence d'une adresse et n'a ni cooldown ni distinction fine des échecs.

**3. Renvoi par `Manager#resend_activation!`** qui vide `confirmation_token` avant d'appeler `resend_confirmation_instructions`. Devise réutilise sinon le token non expiré, et les anciens e-mails resteraient valides.

**4. Inscription : `RegistrationsController` minimal** surchargeant `after_inactive_sign_up_path_for` pour renvoyer vers la page de connexion. Sans cela, Devise redirige vers `root_path`, et l'authentification en place remplace la notice par un « veuillez vous connecter ».

**5. Refus de connexion.** Le message « compte à activer » repose sur le comportement natif de Devise : le mot de passe est vérifié avant `active_for_authentication?`, donc un mauvais mot de passe sur un compte inactif donne le message générique et seul le bon mot de passe obtient `:unconfirmed`. Aucun code spécifique, mais à couvrir par un test.

**6. Migration.** Colonnes `confirmation_token` (index unique), `confirmed_at`, `confirmation_sent_at`, `unconfirmed_email`. Réversible via `up`/`down`. Rattrapage `UPDATE managers SET confirmed_at = CURRENT_TIMESTAMP WHERE confirmed_at IS NULL`, avec l'horodatage de la mise en production plutôt que `created_at`, qui prétendrait une activation qui n'a pas eu lieu.

**7. Réglages mail : module `Fideback::MailerSettings`** (`config/mailer_settings.rb`, requis depuis `application.rb` avant la classe d'application, car les environnements et l'initialiseur Devise le lisent). Chaque valeur : ENV → credentials → défaut. Une valeur ENV vide compte comme absente. Fournit `smtp_settings`, `smtp_configured?` (activé ET adresse, port, identifiant, mot de passe présents), `default_url_options` (`APP_HOST`, `APP_PORT`, `APP_PROTOCOL`) et `mailer_sender` (`SMTP_SENDER` → `MAILER_SENDER` → défaut). Lecture des credentials tolérante à l'absence ou à l'illisibilité de la clé maître. Alternative : écrire les réglages directement dans `production.rb`, écartée parce que l'initialiseur Devise et `ApplicationMailer` doivent aussi lire l'expéditeur.
- Production : SMTP si configuré, sinon `raise_delivery_errors` à true et avertissement au démarrage.
- Développement : SMTP seulement si complet ; sinon letter_opener_web, comme aujourd'hui.
- Test : inchangé.
- L'expéditeur est lu au même endroit par `devise.rb` et `ApplicationMailer`.
- `default_url_options` de dev et de prod passent par le module ; le port par défaut 3000 du dev ne s'applique plus dès que `APP_HOST` est défini (garder le comportement de lockswap : seul `APP_PORT` fixe alors le port).

**8. Déploiement (Kamal).** `SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_DOMAIN` et `SMTP_SENDER` en `env.clear`, `SMTP_PASSWORD` en `env.secret` via `.kamal/secrets`.

**9. Reconfirmation d'adresse.** Aucun code supplémentaire : avec `:confirmable` et `reconfirmable = true`, Devise envoie la confirmation à la nouvelle adresse. Le sujet de l'e-mail reste celui de l'activation (pas de mailer dédié), à réévaluer si cela gêne. La vue d'édition du compte affiche déjà l'adresse en attente.

## Risks / Trade-offs

- [Managers existants bloqués dehors] → rattrapage `confirmed_at` dans la migration, avec un test.
- [SMTP mal configuré en production : personne ne peut s'activer] → avertissement au démarrage, `raise_delivery_errors` en production, page de renvoi.
- [Fixtures de test non confirmées, donc tous les tests d'authentification échouent] → ajouter `confirmed_at` aux fixtures `managers`.
- [Inscription à l'adresse d'un tiers] → le tiers reçoit un e-mail d'activation qu'il peut ignorer ; le compte reste inactif et expire de fait. Pas de purge automatique des comptes jamais activés dans cette change.
- [Le cooldown de 5 minutes se lit sur `confirmation_sent_at`, partagé avec la reconfirmation d'adresse] → acceptable : même fenêtre de limitation pour les deux cas.
- [Adresse prise par un compte inactif] → l'inscription échoue avec « e-mail déjà utilisé » ; l'utilisateur doit passer par le renvoi. Comportement identique à lockswap.

## Migration Plan

1. Déployer le code et lancer la migration (rattrapage des comptes existants inclus).
2. Renseigner les variables `SMTP_*` et le secret avant ou avec le déploiement ; vérifier l'absence d'avertissement au démarrage.
3. Retour arrière : `db:rollback` retire les colonnes ; l'ancien code ignore les managers actifs.
