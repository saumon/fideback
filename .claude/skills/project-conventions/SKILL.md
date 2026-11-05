---
name: project-conventions
description: Conventions de Fideback à connaître avant de modifier le code, les vues ou les tests : interface en français, style visuel, lancement de Ruby et vérifications avant fusion.
user-invocable: false
---

# Conventions Fideback

## Langue
- L'interface est **uniquement en français**. Les textes des vues sont écrits en dur en français ; `config/locales/` ne sert qu'aux modèles/validations, aux statuts (`campaign_status`, `respondent_status`) et aux vues Devise. Suis l'usage existant du fichier que tu modifies, n'introduis pas d'i18n partout.
- Les messages de commit sont des conventional commits **en anglais** (`feat:`, `fix:`…), sans ligne d'attribution.

## Style visuel
- Ton voulu : original, **coloré**, animé, typographie ludique. Un rendu sobre ou monochrome a déjà été rejeté (« trop sobre et terne »).
- Plusieurs couleurs saturées qui portent du sens, des animations visibles, mais toujours avec `prefers-reduced-motion` respecté.
- Police Bricolage Grotesque auto-hébergée dans `app/assets/fonts/` : aucun CDN externe.
- La landing page statique `docs/` (GitHub Pages) a sa propre copie du CSS de l'accueil, `docs/landing.css`, non synchronisée : un changement de style de l'accueil se reporte à la main.
- L'icône a une seule source, `public/icon.svg` ; les versions binaires se régénèrent avec `ruby script/icons`.

## Exécuter les commandes
- Ruby 3.4.6 n'est pas dans le `PATH` du shell. Préfixe :
  `export PATH=/usr/local/rvm/rubies/ruby-3.4.6/bin:$PATH`
- Tests : `bin/rails test` ; tests système (Chrome headless) : `bin/rails test:system`.
- Avant de fusionner : `bin/ci` (RuboCop, bundler-audit, importmap audit, Brakeman, tests, seeds). Il n'inclut pas les tests système.
- Le style Ruby suit RuboCop omakase (`bin/rubocop`).

## Stack
- Rails 8.1, Hotwire (Turbo + Stimulus), importmap, Propshaft, SQLite, Solid Queue/Cache/Cable, Devise.
- En développement, les e-mails sont visibles sur `/letter_opener`.
- Fin de session : `/saumon-finish` (README, vérifications, commit, push).
- Mise à jour Dependabot : `/saumon-dependabot` (choix de la branche, rebase sur `dev`, vérifications, push forcé, merge `--no-ff`).
