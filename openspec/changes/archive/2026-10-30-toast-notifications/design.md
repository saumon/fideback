# Design

## Context

- Les messages flash sont rendus par une boucle `flash.each` identique dans `layouts/application.html.erb` et `layouts/respondent.html.erb`, en `<p class="flash flash-<type>">` au début de `main`.
- La classe `.flash` sert aussi aux bandeaux d'état des vues : `campaigns/_form`, `respondent_forms/show`. Ils partagent leur style avec `#error_explanation` et `#confirmation-outcome` (`application.css`, section « Messages »).
- La stack est Rails 8.1, Turbo 2.0, Stimulus 1.3 et importmap, sans bundler ni bibliothèque UI. Les contrôleurs Stimulus existants sont courts, commentés en français, et n'ont aucune dépendance.
- Le style « chœur » repose sur des tokens (`--jade`, `--danger`, `--ink`, `--surface`, `--bounce`), des bordures de 2px couleur encre et des ombres décalées pleines (`3px 3px 0`).
- Les seuls types de flash émis sont `notice` et `alert`, par les contrôleurs et par Devise. Devise peut aussi poser des clés non textuelles (par ex. `timedout`), que la boucle actuelle afficherait telles quelles.
- Les tests d'intégration vérifient `.flash-notice` / `.flash-alert`. Le test système (Chrome headless, 1400×1400) vérifie le texte des notices juste après les redirections.

## Goals / Non-Goals

**Goals:**
- Un seul composant de toasts, partagé par les deux layouts et rendu côté serveur.
- Aucun ajout à l'importmap : un contrôleur Stimulus et du CSS.
- Les toasts sont toujours au premier plan, sans réglage de `z-index`.

**Non-Goals:**
- Pas d'API JavaScript publique pour créer un toast côté client, ni de diffusion par Turbo Stream. La structure ne doit simplement pas l'empêcher plus tard.
- Pas de changement des textes des messages, ni des endroits du code qui les émettent.

## Decisions

### 1. Un partiel `layouts/_toasts.html.erb`, rendu hors de `main`

Les deux layouts remplacent leur boucle par `render "layouts/toasts"`, placé juste après `main`. Le partiel ne garde que les clés `notice` et `alert` dont la valeur est une chaîne. Il rend :

```
<section class="toasts" aria-label="Notifications" aria-live="polite"
         data-controller="toasts" data-turbo-temporary>
  <div class="toast flash flash-notice" data-toasts-target="toast">
    <p>Campagne clôturée.</p>
    <button type="button" class="toast-close" aria-label="Fermer la notification">×</button>
  </div>
</section>
```

Pour une alerte : `flash-alert` et `role="alert"` sur le `div`. Les classes `flash` et `flash-<type>` restent, ce qui garde valides les `assert_select` existants. Le partiel n'est rendu que s'il y a au moins un message à montrer.

*Écarté :* un helper Ruby qui produirait le HTML. Un partiel suffit et ressemble au reste des vues.

### 2. Le premier plan par l'API Popover, `position: fixed` en secours

À la connexion, le contrôleur pose `popover="manual"` sur la `section`, puis appelle `showPopover()` si `HTMLElement.prototype.showPopover` existe. La section passe alors dans la couche supérieure du navigateur, au-dessus de tout le contenu, quel que soit son contexte d'empilement.

Le CSS annule les styles par défaut d'un popover (`inset`, `margin`, `border`, `padding`, `background`, `overflow`). Il place la section en bas, à droite au-delà de 40rem et au centre en deçà, avec `pointer-events: none` sur la section et `auto` sur chaque toast. Sans popover, ou sans JS, la même règle s'applique en `position: fixed` avec un `z-index` élevé.

*Écarté :* `position: fixed` seul. Cela marche aujourd'hui, mais toute future modale ou tout futur contexte d'empilement repasserait par-dessus.

*Écarté :* un popover par toast. Une seule section dans la couche supérieure garde l'empilement et la mise en page des toasts en CSS ordinaire.

### 3. Annonce fiable : insertion différée dans une zone `aria-live` déjà présente

Un message présent dans le HTML initial n'est pas annoncé de façon fiable. Au `connect`, le contrôleur détache donc les toasts rendus par le serveur. Il attend un court délai (≈ 100 ms), pour que la région vivante vide soit dans l'arbre d'accessibilité, puis les réinsère un par un.

La section est `aria-live="polite"`, ce qui fait lire les notices sans interrompre. Les alertes portent `role="alert"`, ce qui les fait lire immédiatement. Le focus n'est jamais déplacé.

Sans JS, rien n'est détaché et les toasts restent visibles (exigence « Fonctionnement sans JavaScript »).

*Écarté :* rendre le contenu dans un `<template>`. Ce serait invisible sans JS.

*Écarté :* deux zones vivantes cachées doublant le texte visible. Le texte serait en double et le bouton de fermeture introuvable au lecteur d'écran.

### 4. Le minuteur des notices est l'animation de la barre de progression

Chaque notice reçoit une durée `--toast-duration`, calculée par le contrôleur : `clamp(4 s, 3 s + 60 ms × nombre de caractères, 10 s)`. Cela donne environ 4 s pour « Connecté(e). » et environ 6 s pour « Campagne lancée : les invitations sont envoyées. ».

Un pseudo-élément `::after` anime `transform: scaleX(1 → 0)` sur cette durée. Son `animationend` déclenche la sortie du toast.

La pause est purement CSS. `animation-play-state: paused` s'applique sur `:hover` et `:focus-within`, ainsi que sur `.toasts.is-paused`, classe que le contrôleur pose sur `visibilitychange` (onglet caché). La reprise repart donc exactement du temps restant, sans calcul.

Les alertes n'ont ni barre ni minuteur.

*Écarté :* `setTimeout` avec mémorisation du temps restant. C'est plus de code, et la barre et le minuteur risquent de se désynchroniser.

### 5. Sortie, fermeture et balayage

- **Sortie** : tout retrait (minuteur, ×, balayage, éviction) passe par une méthode `dismiss(toast)`. Elle ajoute `is-leaving`, attend la fin de l'animation de sortie, puis retire l'élément. Le bouton × est relié par une action Stimulus.
- **Balayage** :
  - Il utilise les Pointer Events, réservés aux pointeurs `touch` et `pen` : à la souris, le glisser servirait plutôt à sélectionner le texte.
  - Le toast déclare `touch-action: pan-y` et suit le doigt en `translateX`.
  - Au relâchement, il se ferme si le déplacement dépasse 35 % de sa largeur ou si le geste est rapide ; sinon il revient à sa place.
- **Mouvement réduit** : sous `prefers-reduced-motion: reduce`, l'entrée et la sortie deviennent de simples fondus, sans translation ni rebond. La barre de progression reste, car c'est un indicateur de durée et pas un déplacement.

### 6. Empilement : colonne, au plus 3 toasts, éviction des notices seulement

La section est une colonne flex, avec un espace de 0.5rem. Le toast le plus récent est en bas, au plus près du pouce sur mobile.

Après chaque insertion, s'il y a plus de 3 toasts, le contrôleur appelle `dismiss` sur la notice la plus ancienne. S'il n'y a que des alertes, rien n'est retiré, conformément à la spec.

En pratique, une requête ne porte qu'un ou deux messages : cette limite protège surtout l'avenir (Turbo Streams).

### 7. Navigation Turbo

`data-turbo-temporary` retire la section avant que Turbo mette la page en cache. Un retour arrière ne montre donc plus le toast.

Une navigation Turbo remplace le `body`. La section, et donc toute alerte encore ouverte, disparaît avec la page quittée. Le contrôleur ferme le popover dans `disconnect`.

### 8. Apparence

- Carte `--surface`, bordure 2px `--ink`, coins arrondis à 1rem, ombre pleine décalée `4px 4px 0` couleur du type (`--jade` pour une notice, `--danger` pour une alerte).
- Une pastille de couleur avant le texte.
- Barre de progression de 4px en bas de la carte, couleur jade.
- Entrée par le bas avec le rebond `--bounce`, en réutilisant le principe de `flash-in` (nouvelle keyframe `toast-in`).
- Largeur `min(24rem, 100vw − 2rem)` sur desktop, `100% − 2rem` sur mobile.
- Décalage `max(1rem, env(safe-area-inset-bottom))` en bas et `env(safe-area-inset-left/right)` sur les côtés.

### 8 bis. Au-dessus d'une barre d'actions collée en bas

Le formulaire du sondé a une barre « Enregistrer / Soumettre » collée en bas de l'écran (`.answer-actions`, `position: sticky`). En bas, une alerte persistante comme « Il manque des notes » couvrirait le bouton Soumettre.

La barre porte donc `data-toasts-avoid`. Le contrôleur mesure sa hauteur avec un `ResizeObserver` et la reporte dans `--toasts-lift`, qui soulève la colonne de toasts d'autant.

*Écarté :* une hauteur fixe en CSS. Sur mobile, les deux boutons passent sur deux lignes et la hauteur change.

### 9. Les bandeaux d'état deviennent `.callout`

Dans `campaigns/_form` et `respondent_forms/show`, `flash flash-notice` devient `callout`, et `flash flash-alert` devient `callout callout-alert`. Dans `application.css`, le sélecteur partagé `.flash, #error_explanation, #confirmation-outcome` devient `.callout, #error_explanation, #confirmation-outcome`. Le style actuel de ces bandeaux est conservé tel quel.

La seule assertion de test qui visait ces bandeaux, `respondent_forms_test.rb` `/terminée/`, passe à `.callout-alert`. Les `.flash-alert` de `campaigns_test.rb` et `respondents_test.rb` visent des flash après redirection, devenus des toasts : elles restent inchangées.

## Risks / Trade-offs

- **Double apparition au chargement** : le contrôleur détache les toasts déjà peints puis les réinsère. → Sous `@media (scripting: enabled)`, les toasts restent masqués tant que la colonne n'a pas `data-ready`. Sans JavaScript, la requête média ne s'applique pas et les toasts restent visibles. Contrepartie : si le JavaScript est actif mais que le contrôleur ne se charge pas (erreur de module), les toasts restent masqués.
- **Mouvement réduit** : la règle globale `animation: none !important` arrêterait la barre, donc le minuteur, et une notice ne se fermerait plus. → Exceptions explicites pour `.toast` (fondu) et `.toast.is-timed::after` (barre) dans le bloc `prefers-reduced-motion`. Les règles de pause sont en `!important` pour garder la priorité.
- **Un toast peut recouvrir un bouton en bas à droite**, dans l'app ou pendant un test système (« element click intercepted »). → Les toasts sont petits et éphémères, et la section laisse passer les clics hors des toasts. Dans les tests système, attendre la disparition du toast ou le fermer avant de cliquer en dessous.
- **Popover non pris en charge** (navigateurs antérieurs à 2024). → Repli `position: fixed`, testé en retirant l'attribut.
- **Mobile sans JS** : une alerte ne peut pas être fermée et couvre le bas de l'écran. → Le cas est marginal (Turbo et le formulaire de notes reposent déjà sur JS) et l'alerte disparaît à la navigation suivante.
- **Lecteurs d'écran** : le délai avant réinsertion est empirique. → Le vérifier avec VoiceOver sur iOS et NVDA. Ces tests se font à la main, d'où une tâche de vérification manuelle.
