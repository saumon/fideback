# Design

## Context

La navigation est un `<nav>` unique dans `app/views/layouts/application.html.erb`, qui contient les liens, le bouton « Se déconnecter » et, pour un visiteur, le bouton « Créer un compte ». Elle n'a aucune règle mobile : elle passe à la ligne et occupe environ 130 px sur 380 px de large. L'application utilise déjà Stimulus (importmap, contrôleurs `toasts`, `role_filter`), et le breakpoint des petits écrans est `40rem`. Turbo Drive remplace le `<body>` à chaque navigation. La barre active et `current_nav_section` existent déjà (voir le spec `main-navigation`). Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Un en-tête mobile d'une seule ligne et un tiroir accessible au clavier et aux lecteurs d'écran.
- Dégrader proprement sans JavaScript.
- Réutiliser la barre active existante, sans la réécrire.

**Non-Goals:**
- Modifier la navigation sur grand écran.
- Ajouter une bibliothèque de menu ou de gestion du focus.

## Decisions

- **Un seul `<nav>`, mis en forme par le CSS.** Le même balisage sert au bureau (barre horizontale) et au mobile (tiroir). On n'en duplique pas le contenu. Alternative écartée : un second `<nav>` réservé au mobile, qui doublerait les liens pour les lecteurs d'écran et pour les tests.
- **« Créer un compte » sort du `<nav>`.** Il devient un frère du `<nav>` dans un conteneur `.header-end` de l'en-tête (avec le bouton de menu), pour rester visible quand le tiroir est fermé. Sur grand écran l'ordre visuel est inchangé (liens, puis bouton). Ce n'est pas une entrée de menu, ce que le spec dit déjà.
- **Le bloc compte est regroupé.** Le nom du manager et « Se déconnecter » sont dans un `div.nav-account` avec un libellé « Connecté » et un trait de séparation, qui n'apparaissent que dans le tiroir. Sur grand écran, `display: contents` garde la mise en page actuelle.
- **Amélioration progressive par `data-nav-ready`.** Le bouton de menu est rendu `hidden`. Le contrôleur `nav-drawer` le révèle et pose `data-nav-ready` sur l'en-tête à sa connexion ; les règles du tiroir ne s'appliquent que sous `40rem` et seulement avec cet attribut. Sans JavaScript, la navigation reste l'empilement actuel. Même principe que `data-ready` des toasts. Alternative écartée : `<details>`, qui offre moins de contrôle sur l'animation, le focus et l'inertie de la page.
- **Contrôleur Stimulus `nav_drawer_controller.js`.** Il gère l'état (`is-open` sur l'en-tête), `aria-expanded` et le nom accessible du bouton, la touche Échap, le piège à focus (Tab et Maj+Tab bouclent entre le bouton et les éléments du tiroir), `inert` sur `<main>` et sur le pied de page de développement, et le blocage du défilement (`overflow: hidden` sur `<html>`). Il rend le focus au bouton à la fermeture et place le focus sur la première entrée à l'ouverture. Il pose `--i` (rang) sur chaque entrée pour la cascade.
- **Fermetures.** Clic sur le fond (`data-action`), clic sur un lien (Turbo remplace ensuite le `<body>`), Échap, passage au-dessus de `40rem` (`matchMedia`), et `turbo:before-cache`, pour qu'un retour dans l'historique ne ressorte pas un instantané avec le tiroir ouvert.
- **Animations en CSS pur.** Le tiroir glisse par `transform: translateX`, avec `visibility` retardée à la fermeture pour qu'il ne reste pas atteignable au clavier ; le fond passe par `opacity`. Les entrées arrivent en cascade par `animation` (`from` seulement, `both`) avec un délai de `--i`. Les entrées sont visibles par défaut : sous `prefers-reduced-motion`, la règle globale existante coupe animations et transitions et tout s'affiche sans glissement ni cascade.
- **Barre active dans le tiroir.** Sous `40rem` avec `data-nav-ready`, l'animation d'ouverture et la boucle de la barre ne démarrent que sous `.is-open`, après le glissement, pour que le déroulement soit visible. Hors de ce cas, le CSS actuel est inchangé.
- **Cibles tactiles.** Les entrées du tiroir font au moins 3 rem de haut. Le tiroir prend `min(82%, 19rem)`, tient compte des zones sûres (`env(safe-area-inset-*)`) et défile s'il est plus haut que l'écran.

## Risks / Trade-offs

- [Logo + « Créer un compte » + bouton ne tiennent pas sur 320 px] → réduire le remplissage du bouton et masquer les points du logo sous environ 24 rem ; à vérifier à 320 px lors de l'implémentation.
- [`inert` ou le piège à focus oublient un élément ajouté plus tard] → le contrôleur rend inertes `<main>` et le pied de page de développement, couverts par un test système ; tout nouvel élément hors de l'en-tête devra y figurer.
- [Un instantané du cache Turbo avec le tiroir ouvert] → fermeture sur `turbo:before-cache`, couverte par un test.
- [Un nom de manager très long déborde du tiroir] → retour à la ligne dans l'entrée (`overflow-wrap: anywhere`).
- [Le toast, dans la couche supérieure du navigateur, passe au-dessus du tiroir] → accepté : il est transitoire et déjà positionné pour ne pas masquer le bouton de menu.
