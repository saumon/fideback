# Tasks

## 1. Socle statique

- [x] 1.1 Créer `docs/.nojekyll`, copier la police dans `docs/fonts/bricolage-grotesque.woff2` et l'icône dans `docs/icon.svg` ; vérifier que les fichiers existent et sont identiques aux sources (`cmp`)
- [x] 1.2 Créer `docs/landing.css` : variables, base, en-tête, logo, voix, boutons, règles `.home-*` copiés de `application.css`, avec commentaire de resynchronisation en tête et `prefers-reduced-motion` ; vérifier qu'il n'y a aucune URL externe (`grep -n "http" docs/landing.css`)

## 2. Page d'accueil reprise

- [x] 2.1 Créer `docs/index.html` avec en-tête (logo SVG animé, bouton GitHub à logo inline), hero au titre mot par mot, scène « Gaspard » et trois étapes, repris de `home.html.erb` en HTML statique ; vérifier que la page s'ouvre sans JS et que l'arrivée du logo, des mots et de la scène s'anime
- [x] 2.2 Remplacer les boutons de compte par « Voir sur GitHub » vers `https://github.com/saumon/fideback` (hero et en-tête) ; vérifier avec `grep` qu'aucun lien « Se connecter » ou « Créer un compte » n'existe

## 3. Sections de présentation

- [x] 3.1 Ajouter les sections problème, fonctionnalités en cartes colorées, transparence des réponses nominatives et open source / auto-hébergement, avec les styles dans `landing.css` ; vérifier que leur contenu correspond au README et à `docs/fonctionnement.md`
- [x] 3.2 Ajouter le bandeau final avec le bouton GitHub répété ; vérifier que les trois boutons GitHub pointent vers la même URL

## 4. Partage et référencement

- [x] 4.1 Ajouter `title`, `description`, `canonical`, Open Graph, Twitter Card et icônes dans `<head>`, avec les liens de ressources relatifs et seules les URL de partage absolues ; vérifier les balises avec `grep`
- [x] 4.2 Produire `docs/og.png` en 1200x630 depuis le logo et le titre ; vérifier ses dimensions (`file docs/og.png`) et qu'elle est référencée par `og:image` et `twitter:image`

## 5. Vérifications et documentation

- [x] 5.1 Contrôler la page dans un navigateur à 360 px et 1280 px, avec et sans mouvement réduit : pas de défilement horizontal, contrastes lisibles, animations arrêtées en mouvement réduit
- [x] 5.2 Vérifier qu'aucune requête externe n'est faite hors lien GitHub, et que tous les liens relatifs se résolvent aussi sous le préfixe `/fideback/` (serveur local sur un sous-dossier)
- [x] 5.3 Mettre à jour le README (section Déploiement : landing, réglage Pages « branche `master`, dossier `/docs` ») et `project-conventions` (rappel de resynchroniser `docs/landing.css`) ; vérifier les liens ajoutés
- [x] 5.4 Lancer `bin/ci` pour vérifier que l'application n'est pas affectée

## Workflow follow-up

- Fusionner `dev` dans `master`, puis activer Pages dans les paramètres du dépôt (Deploy from a branch, `master`, `/docs`) et vérifier `https://saumon.github.io/fideback/`.
- Archiver le changement une fois la revue passée.
