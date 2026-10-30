# Proposal

## Why

Une adresse inconnue, ou une page réservée que l'on n'a pas le droit de voir (`/admin` sans être Admin), aboutit aujourd'hui à `public/404.html` : une page autonome, correcte mais anonyme, sans la police, la barre du haut ni l'humeur de Fideback. Un 404 est un moment où l'on quitte l'application ; autant qu'il soit dans le style du site, et qu'il fasse sourire.

## What Changes

- Toute adresse inconnue, et tout enregistrement introuvable (par exemple un lien de sondé inconnu), affiche une page 404 dans le style de Fideback : la barre du haut, la police et les couleurs du site, des animations, et un ton drôle.
- Le texte et l'illustration de la page reprennent l'univers de l'application : la synthèse de feedback, ses voix colorées et sa note moyenne.
- La page propose toujours un retour : vers l'accueil (ou les campagnes pour un manager connecté).
- Le refus de `/admin` à un manager non Admin affiche la même page, y compris en développement.
- Dans l'espace des sondés (`/repondre/...`), la page n'affiche pas les liens de compte.
- En développement, la page est consultable sur `/dev/404`, pour la retoucher sans provoquer d'erreur.
- `public/404.html` reste en place comme page de secours si le rendu dynamique échoue ; les autres pages d'erreur ne changent pas.

## Capabilities

### New Capabilities
- `not-found-page`: ce que le visiteur voit et peut faire sur une page introuvable, quelle que soit la cause.

### Modified Capabilities

## Impact

- Nouveau contrôleur d'erreurs, vue, styles et configuration de l'application (`config.exceptions_app`), plus la route `/404`.
- `Admin::BaseController` : rend la page au lieu de lever une erreur.
- `app/assets/stylesheets/application.css` : styles et animation de la page.
- Tests d'intégration ; `public/404.html` inchangé (le test des icônes continue de le vérifier).
- Aucune dépendance nouvelle.
