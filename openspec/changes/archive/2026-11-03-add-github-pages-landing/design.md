# Design

## Context

La page d'accueil de l'application (`app/views/pages/home.html.erb`) est du HTML plus du CSS pur dans `app/assets/stylesheets/application.css` (un seul fichier, hashé par Propshaft). Les animations (logo, mots, scène) sont entièrement en CSS ; le contrôleur Stimulus `brand_mark` ne sert qu'à ne pas rejouer l'arrivée des bulles après une navigation Turbo, ce qui n'existe pas sur une page statique. La police est `app/assets/fonts/bricolage-grotesque.woff2`, l'icône `public/icon.svg`. `docs/` contient déjà `fonctionnement.md`. Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Page autonome qui se sert telle quelle depuis `docs/`, sans build.
- Rendu fidèle à l'accueil déconnecté, plus des sections de présentation dans le même ton.
- Respect des conventions : français, couleurs saturées, `prefers-reduced-motion`, aucun CDN.

**Non-Goals:**
- Synchronisation automatique avec `application.css` ou prérendu de la vraie page Rails.
- Workflow GitHub Actions, domaine personnalisé, JavaScript, multilingue, analytics.

## Decisions

- **Copie manuelle et réduite du CSS** dans `docs/landing.css` (décision utilisateur) plutôt qu'un script de génération ou un prérendu. Elle reprend les variables, la base, l'en-tête, le logo, les voix, les boutons, les règles `.home-*` et le mouvement réduit, et ajoute les nouvelles sections. Un commentaire en tête rappelle de resynchroniser quand le style de l'accueil change. Alternative écartée : script de copie (source unique, mais CSS inutile embarqué et outil en plus).
- **Aucun JavaScript.** L'arrivée des bulles se joue à chaque chargement, ce qui est le comportement voulu sur une page ouverte une fois. La navigation en tiroir de l'application n'a pas d'équivalent : l'en-tête ne contient que le logo et le bouton GitHub.
- **Liens relatifs** (`landing.css`, `fonts/…`, `icon.svg`, `og.png`) pour que la page marche sur un préfixe `/fideback/` comme à la racine. Seules les balises `canonical`, `og:url` et `og:image` sont absolues, car les réseaux sociaux l'exigent.
- **Logo GitHub en SVG inline** (`fill: currentColor`, `aria-hidden`), pour éviter tout CDN et suivre la couleur du bouton.
- **Image de prévisualisation `og.png`** 1200x630 produite une fois à partir du logo et du titre, puis commitée. Format PNG, car les réseaux sociaux n'acceptent pas le SVG.
- **Police copiée** dans `docs/fonts/` avec `font-display: swap` et un `<link rel="preload">`, comme dans le layout de l'application.
- **Sections ajoutées en réutilisant le vocabulaire visuel** : cartes colorées par voix pour les fonctionnalités, bloc de transparence, bandeau final avec le bouton GitHub. Le contenu est tiré de `README.md` et `docs/fonctionnement.md`.
- **`.nojekyll`** pour désactiver Jekyll. Conséquence : `docs/fonctionnement.md` reste servi en texte brut. Il est laissé en place.
- **Pas de test automatisé côté Rails** : la page est hors de l'application. La vérification passe par un contrôle des liens et des ressources (aucune URL externe hors GitHub) et par un rendu réel dans un navigateur à 360 px et 1280 px, avec et sans mouvement réduit.

## Risks / Trade-offs

- [Dérive entre `landing.css` et `application.css`] → commentaire de resynchronisation dans le CSS, mention dans `project-conventions`, et dans le README.
- [La landing n'est en ligne qu'après la fusion de `dev` dans `master`] → à rappeler au moment de la livraison.
- [Le réglage GitHub Pages est manuel] → décrit dans les tâches et le README, avec vérification de l'URL publiée.
- [`fonctionnement.md` exposé en texte brut] → accepté, il est déjà public dans le dépôt.
- [Les images de partage sont mises en cache par les réseaux sociaux] → versionner le nom de `og.png` si l'image change.
