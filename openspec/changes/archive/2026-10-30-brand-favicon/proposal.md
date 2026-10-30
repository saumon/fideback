# Proposal

## Why

L'onglet de Fideback affiche encore le rond rouge générique de Rails (`public/icon.svg`, `public/icon.png`), sans rapport avec l'identité colorée du site. L'espace des sondés et les pages d'erreur ne déclarent aucune icône. Le navigateur y demande `/favicon.ico`, qui n'existe pas : un 404 à chaque visite, et un onglet sans icône pour les personnes extérieures qui reçoivent l'invitation.

## What Changes

- Nouvelle icône d'application, piste C retenue sur maquette : un « F » encre, condensé et gras comme les titres du site, avec une ombre rose (`--pink`) décalée vers le bas à droite, comme les boutons. Fond transparent.
- En thème sombre du système, le F passe en clair (`#F7F5FC`, le fond de l'app), sans changer l'ombre. Sinon, le F encre disparaîtrait sur un onglet sombre.
- Les fichiers d'icône sont remplacés ou ajoutés :
  - `icon.svg` : navigateurs modernes, variante sombre incluse ;
  - `icon.png` 512 px : manifeste et Safari ;
  - `apple-touch-icon.png` 180 px : le F posé sur le fond clair de l'app, au lieu du fond noir qu'iOS imposerait ;
  - `favicon.ico` : requête automatique des navigateurs.
- Les liens d'icône sont déclarés partout : layout manager (déjà fait), layout sondé et pages d'erreur statiques.
- Un script reproductible génère les PNG et l'ICO depuis les sources SVG.

## Capabilities

### New Capabilities
- `app-icon`: icône de l'application dans les onglets, favoris et écrans d'accueil : présence sur toutes les pages, lisibilité selon le thème, variantes par plateforme.

### Modified Capabilities

Aucune.

## Impact

- Fichiers publics :
  - `public/icon.svg` et `public/icon.png` sont remplacés ;
  - nouveaux fichiers `public/apple-touch-icon.png` et `public/favicon.ico` ;
  - liens d'icône ajoutés à `public/4xx.html` et `public/500.html`.
- Vues : `layouts/application.html.erb` (pointer vers `apple-touch-icon.png`), `layouts/respondent.html.erb` (ajout des liens).
- Outillage : nouveau script `script/icons`, qui fait rendre les SVG par Chrome headless via `selenium-webdriver`, déjà présent dans le groupe de test. Aucune nouvelle gem.
- Hors périmètre :
  - activation de la PWA (routes `pwa` commentées) ;
  - couleurs `theme_color` / `background_color` du manifeste, encore rouges, mais inutilisées tant que la PWA est désactivée ;
  - icône animée.
