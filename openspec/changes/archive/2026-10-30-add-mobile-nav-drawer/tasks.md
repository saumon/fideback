## 1. Balisage

- [x] 1.1 Dans `app/views/layouts/application.html.erb`, rattacher l'en-tête au contrôleur `nav-drawer`, regrouper le `<nav>`, « Créer un compte » (hors `<nav>`) et le bouton de menu (`hidden`, `aria-controls`, `aria-expanded="false"`, nom « Ouvrir le menu ») dans un `.header-end`, et ajouter le fond assombri
- [x] 1.2 Regrouper le nom du manager et « Se déconnecter » dans un `div.nav-account` avec le libellé « Connecté »

## 2. Contrôleur Stimulus

- [x] 2.1 Créer `app/javascript/controllers/nav_drawer_controller.js` : ouverture et fermeture, `aria-expanded` et nom accessible, `data-nav-ready`, rangs `--i`
- [x] 2.2 Ajouter Échap, clic sur le fond, passage au-dessus de `40rem` (`matchMedia`) et `turbo:before-cache` comme causes de fermeture
- [x] 2.3 Ajouter le piège à focus (Tab et Maj+Tab), `inert` sur `<main>` et le pied de page, le blocage du défilement, le focus sur la première entrée à l'ouverture et son retour au bouton à la fermeture

## 3. Styles

- [x] 3.1 Dans `application.css`, sous `40rem` avec `data-nav-ready` : en-tête d'une ligne (logo à gauche, `.header-end` à droite), bouton de menu à trois barres qui deviennent une croix, tiroir latéral, fond assombri, cibles de 3 rem, zones sûres
- [x] 3.2 Styler le bloc compte du tiroir (libellé « Connecté », trait de séparation) et le masquer proprement sur grand écran (`display: contents`)
- [x] 3.3 Animer le glissement, le fond et la cascade des entrées ; faire démarrer le déroulement de la barre active et sa boucle à l'ouverture du tiroir
- [x] 3.4 Vérifier que les animations disparaissent sous `prefers-reduced-motion` sans laisser d'entrée masquée, et que la barre reste complète
- [x] 3.5 Contrôler le rendu à 320 px (logo, « Créer un compte » et bouton de menu) et ajuster

## 4. Tests

- [x] 4.1 Tests d'intégration du balisage : bouton de menu et attributs ARIA, « Créer un compte » hors du `<nav>`, contenu du `<nav>` pour un visiteur, un manager et un Admin, bloc compte ; mettre à jour les tests existants sur la navigation si besoin
- [x] 4.2 Test système (Chrome headless, écran étroit) : ouverture, croix, fermeture par Échap, par le fond et par un lien, focus piégé puis rendu, page inerte et défilement bloqué
- [x] 4.3 Test système : un retour dans l'historique après ouverture du tiroir affiche le tiroir fermé ; sur grand écran, le bouton de menu n'est pas affiché

## 5. Vérification

- [x] 5.1 Contrôler dans un navigateur le tiroir sur écran étroit (visiteur, manager, Admin), avec et sans mouvement réduit, puis à plus de `40rem`
- [x] 5.2 Lancer `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, puis `bin/ci` avant fusion
