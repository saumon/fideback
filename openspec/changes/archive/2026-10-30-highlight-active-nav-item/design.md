# Design

## Context

La navigation est écrite en dur dans `app/views/layouts/application.html.erb`, avec des `link_to` sans aucun état. Le `<body>` porte déjà `page-<controller_name>`, mais `controller_name` ne distingue pas `admin/users` de `users` ni les contrôleurs Devise des autres. Les écrans d'une campagne dépendent de plusieurs contrôleurs (`campaigns`, `summaries`, `respondents`). Voir proposal.md pour la motivation.

## Goals / Non-Goals

**Goals:**
- Déterminer la section courante à un seul endroit, testable, sans dupliquer la logique dans le layout.
- Un état lisible par les technologies d'assistance, qui sert aussi de crochet CSS.

**Non-Goals:**
- Refondre la navigation ou la rendre configurable.
- Mettre en évidence le bouton « Créer un compte » ni les liens hors de la navigation principale.

## Decisions

- **Section déduite du contrôleur, via `controller_path`.** Un helper `current_nav_section` dans `ApplicationHelper` associe le chemin du contrôleur à une section : `campaigns`, `summaries` et `respondents` donnent les campagnes ; `teams` donne l'équipe ; tout contrôleur sous `admin/` donne l'administration ; `managers/registrations` donne le compte ; `devise/sessions` donne la connexion ; le reste donne `nil`. Alternative écartée : `current_page?`, qui compare des adresses exactes et ne reconnaît ni `/campaigns/12/edit` ni `/admin/users` comme appartenant à leur section. Alternative écartée : un `content_for :nav` posé par chaque vue, qui disperse la règle dans une vingtaine de fichiers et se perd à l'ajout d'un écran.
- **Un helper de lien, `nav_link(label, path, section)`.** Il ajoute `aria-current="page"` quand `section == current_nav_section`. Le layout l'utilise pour les quatre entrées du menu et « Se connecter ». Le style cible `nav a[aria-current="page"]`, sans classe supplémentaire, pour que l'état accessible et l'état visuel ne puissent pas diverger.
- **Page introuvable.** `ErrorsController` n'est dans aucune section, donc rien n'est surligné. Le cas où `Admin::BaseController` rend la page introuvable à un non-Admin est sans conséquence, puisque ce manager n'a pas de lien « Administration » à surligner.
- **Style : barre en pseudo-élément, validée sur maquette.** `a::after` porte un dégradé rose, safran, jade, azur, rose (même couleur aux deux bouts, pour une boucle sans à-coup), sous le texte. Une barre masquée par `scaleX(0)` sur les liens inactifs ; sur le lien `aria-current`, elle est à `scaleX(1)`.
- **Animations : deux `animation` CSS, pas de JavaScript.** Turbo Drive remplace le `<body>` à chaque navigation : le lien actif est donc un élément neuf et l'animation d'ouverture (`scaleX(0)` à `scaleX(1)`, rebond `--bounce`, `both`) se joue à chaque clic sur le menu, sans code supplémentaire. La boucle fait défiler le dégradé (`background-size: 200%`, `background-position` de 0 à 200 %, `linear infinite`, environ 3 s). Les deux sont chaînées dans une même propriété `animation`. Alternative écartée : un contrôleur Stimulus qui déclencherait l'ouverture au clic, plus de code pour un résultat identique.
- **Mouvement réduit.** La règle globale `prefers-reduced-motion` de `application.css` coupe déjà toute `animation`. Comme l'état de repos (`scaleX(1)`, dégradé fixe) est défini hors des keyframes, la barre reste complète et immobile.
- **Retour à la ligne sur mobile.** L'espacement vertical du menu (`gap: 0.25rem …`) passe à environ `0.75rem`, pour que la barre d'une ligne ne touche pas la suivante.

## Risks / Trade-offs

- [Un nouveau contrôleur ajouté plus tard n'est dans aucune section] → il n'est simplement pas surligné ; la table de correspondance est courte et couverte par des tests par section.
- [Une animation infinie sur chaque écran distrait ou coûte du rendu] → elle ne porte que sur la barre d'un seul lien (`background-position`, sur un élément de 5 px) et s'arrête en mouvement réduit.
- [Le gras élargit légèrement le lien actif et décale les voisins] → réserver la largeur du gras pour tous les liens ; à vérifier visuellement lors de l'implémentation.
- [Le lien portant le nom du manager peut être long] → il garde son retour à la ligne existant ; la barre suit la largeur du lien.
