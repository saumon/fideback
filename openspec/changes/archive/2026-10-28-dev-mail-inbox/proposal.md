# Proposal

## Why

Fideback envoie des emails (invitation des sondés) mais aucun mécanisme ne permet de les voir en développement : le `delivery_method` par défaut est SMTP sur localhost et échoue. Tester le parcours manager → sondé oblige aujourd'hui à fouiller les logs pour retrouver le lien personnel. Le projet `saumon/lockswap` a déjà résolu ce problème avec `letter_opener_web`.

## What Changes

- Ajouter le gem `letter_opener_web` au groupe `:development`.
- Configurer `config.action_mailer.delivery_method = :letter_opener_web` en développement : tous les emails sont interceptés, aucun n'est envoyé.
- Monter `LetterOpenerWeb::Engine` sur `/letter_opener`, uniquement si `Rails.env.development?`.
- Afficher en bas de page un lien vers `/letter_opener`, uniquement en développement, dans les deux layouts HTML (`application` et `respondent`) via un partial commun.
- Hors périmètre : module de configuration SMTP à la `Lockswap::MailerSettings`, configuration d'envoi en production, changement du contenu des emails.

## Capabilities

### New Capabilities

Aucune : outillage de développement, sans changement de comportement produit (le change déclare `skip_specs: true`).

### Modified Capabilities

Aucune.

## Impact

- `Gemfile` / `Gemfile.lock` : nouveau gem en groupe `:development`.
- `config/environments/development.rb` : `delivery_method`.
- `config/routes.rb` : montage conditionnel de l'engine.
- `app/views/layouts/application.html.erb`, `app/views/layouts/respondent.html.erb` et nouveau partial `app/views/layouts/_dev_footer.html.erb`.
- `app/assets/stylesheets/application.css` : style discret du footer.
- Production et test inchangés (le test garde `delivery_method = :test`).
