# Tasks

## 1. Source vectorielle

- [x] 1.1 Remplacer `public/icon.svg` par le dessin validé, avec la règle `prefers-color-scheme: dark` qui passe le F en `#F7F5FC` (design §1). Vérifier dans Chrome, en émulant le thème clair puis sombre dans les DevTools, que l'onglet montre le F encre puis le F clair, l'ombre rose restant identique.

## 2. Génération des fichiers binaires

- [x] 2.1 Écrire `script/icons` (design §3). Il rend `public/icon.png` (512 px, transparent), `public/apple-touch-icon.png` (180 px, F à environ 70 % sur fond `#F7F5FC` plein) et `public/favicon.ico` (PNG 16, 32 et 48 px) à partir de `public/icon.svg`. Vérifier en lançant le script : les quatre fichiers existent, et `file public/*.png public/favicon.ico` annonce les bonnes dimensions et le format ICO.
- [x] 2.2 Contrôler visuellement les fichiers produits, en ouvrant les PNG et `favicon.ico` : F encre et ombre rose, transparence de `icon.png`, fond clair plein de `apple-touch-icon.png`, plus aucune trace du rond rouge.
- [x] 2.3 Documenter `script/icons` dans le README : quand le relancer (après une modification de `public/icon.svg`) et son prérequis, Chrome comme pour les tests système. Vérifier que la commande documentée fonctionne telle qu'écrite.

## 3. Déclaration de l'icône sur toutes les pages

- [x] 3.1 Dans `layouts/application.html.erb`, pointer `apple-touch-icon` vers `/apple-touch-icon.png`. Ajouter les liens `icon.png`, `icon.svg` et `apple-touch-icon.png` dans `layouts/respondent.html.erb`.
- [x] 3.2 Ajouter les liens `icon.svg` et `icon.png` dans `public/400.html`, `404.html`, `406-unsupported-browser.html`, `422.html` et `500.html`.
- [x] 3.3 Ajouter un test d'intégration :
  - la page d'accueil et le formulaire d'un sondé déclarent `link[rel=icon][href='/icon.svg']` et `link[rel=apple-touch-icon][href='/apple-touch-icon.png']` ;
  - chaque page d'erreur de `public/` contient le lien vers `/icon.svg` ;
  - `public/favicon.ico` existe et commence par l'en-tête ICO.

  Vérifier avec `bin/rails test`.

## 4. Vérification d'ensemble

- [x] 4.1 Lancer `bin/rails test`, `bin/rails test:system` et `bin/rubocop`, et vérifier que tout passe.
- [x] 4.2 Vérifier à la main dans un navigateur, en rechargeant sans cache :
  - l'onglet de l'espace manager, de l'espace sondé et d'une page 404, en thème clair et sombre ;
  - `/favicon.ico` renvoie l'icône ;
  - sur iPhone si possible, l'ajout à l'écran d'accueil montre le F sur fond clair.
