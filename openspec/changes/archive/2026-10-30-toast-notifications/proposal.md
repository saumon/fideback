# Proposal

## Why

Les messages qui suivent une action (« Connecté(e). », « Déconnecté(e). », « Campagne clôturée. », « Invitation renvoyée à … ») sont aujourd'hui insérés en tête de `main`, dans le flux : ils poussent toute la page vers le bas et restent affichés jusqu'à la navigation suivante. Sur mobile, ils occupent une bonne part du premier écran.

## What Changes

- Les messages flash des deux layouts (`application`, `respondent`) deviennent des toasts posés au premier plan, en bas à droite sur desktop, en bas au centre et pleine largeur sur mobile. Ils ne décalent plus aucun élément de l'interface.
- Les notices disparaissent seules après quelques secondes, selon la longueur du texte. Le minuteur s'arrête au survol, au focus et quand l'onglet est caché, et une barre de progression montre le temps restant.
- Les alertes restent affichées jusqu'à ce qu'on les ferme. Cela inclut « Il manque des notes… », gardé comme toast de rappel ; les champs restent signalés dans le formulaire.
- Chaque toast se ferme avec un bouton × ou d'un balayage. La pile est limitée ; quand elle déborde, ce sont les notices les plus anciennes qui partent, jamais une alerte.
- Les toasts sont annoncés aux lecteurs d'écran, poliment pour une notice, immédiatement pour une alerte. Leurs animations respectent `prefers-reduced-motion`, et ils ne réapparaissent pas quand on revient en arrière avec le cache Turbo.
- Les bandeaux d'état posés dans les vues (« Vous avez soumis vos réponses… », « Cette campagne est terminée… », erreurs de `campaigns/_form`, `#confirmation-outcome`) restent dans la page. Ils quittent la classe `.flash` pour une classe `.callout`, afin de ne pas hériter du style des toasts.

## Capabilities

### New Capabilities
- `ui-notifications`: affichage des messages consécutifs à une action (toasts) : placement au premier plan, durée de vie selon le type, fermeture, empilement, accessibilité et comportement à la navigation.

### Modified Capabilities

Aucune. Les specs existantes parlent de « message » sans en fixer la forme ; les messages d'état qu'elles décrivent (campagne terminée, réponses déjà soumises, issue d'une confirmation) restent dans la page.

## Impact

- Vues : `layouts/application.html.erb`, `layouts/respondent.html.erb`, nouveau partiel de toasts, `campaigns/_form.html.erb`, `respondent_forms/show.html.erb`.
- JavaScript : nouveau contrôleur Stimulus `toast`. Aucune nouvelle dépendance (importmap inchangé).
- CSS : `application.css` (styles des toasts, nouvelle classe `.callout`, animations).
- Tests : les classes `flash-notice` / `flash-alert` restent sur les toasts. Les assertions sur les bandeaux des vues (par ex. `/terminée/`) suivent le renommage.
- Hors périmètre : toasts déclenchés côté client sans requête serveur, Turbo Streams de notification, refonte des messages d'erreur de champ.
