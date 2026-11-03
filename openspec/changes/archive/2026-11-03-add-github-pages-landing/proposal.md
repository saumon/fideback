# Proposal

## Why

Fideback n'a aujourd'hui aucune vitrine publique : la seule page d'accueil est celle de l'application, dont les boutons mènent à une connexion et à une création de compte. Pour les campagnes marketing, il faut une page statique qui présente le projet et envoie vers son dépôt GitHub, sans serveur Rails.

## What Changes

- Ajout d'une landing page statique dans `docs/`, servie par GitHub Pages à `https://saumon.github.io/fideback/` (branche `master`, dossier `/docs`).
- La page reprend le style, le visuel et les animations de l'accueil déconnecté : logo à deux bulles animé, titre mot par mot, scène de synthèse « Gaspard », voix colorées, `prefers-reduced-motion` respecté.
- Les boutons « Se connecter » et « Créer un compte » sont remplacés par un bouton « Voir sur GitHub » portant le logo GitHub, vers `https://github.com/saumon/fideback`.
- La page présente le projet : problème, étapes, fonctionnalités, transparence des réponses nominatives, open source et auto-hébergement.
- Page autonome : feuille de style copiée et réduite, police et icône locales, aucun JavaScript, aucun CDN, chemins relatifs.
- Métadonnées de partage (description, Open Graph, Twitter Card, URL canonique) et image de prévisualisation.

Hors périmètre : toute modification de l'application Rails, un workflow GitHub Actions, un domaine personnalisé, la synchronisation automatique du CSS avec celui de l'application.

## Capabilities

### New Capabilities
- `landing-page`: vitrine statique du projet publiée avec GitHub Pages, fidèle au style de l'accueil, dont l'unique appel à l'action mène au dépôt GitHub.

### Modified Capabilities

## Impact

- Nouveaux fichiers dans `docs/` : `index.html`, `landing.css`, `fonts/bricolage-grotesque.woff2`, `icon.svg`, `og.png`, `.nojekyll`.
- `docs/fonctionnement.md` reste dans `docs/` et devient accessible en texte brut sur Pages.
- Réglage manuel du dépôt GitHub : Pages, « Deploy from a branch », `master`, `/docs`. La page n'est en ligne qu'après la fusion de `dev` dans `master`.
- La feuille de style de la landing est une copie : elle peut diverger de `application.css`.
- README et convention du projet : mentionner la landing et le rappel de resynchronisation.
