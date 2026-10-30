# Tasks

## 1. Bandeaux d'état en `.callout`

- [x] 1.1 Renommer les bandeaux de `campaigns/_form.html.erb` et `respondent_forms/show.html.erb` : `flash flash-notice` devient `callout`, `flash flash-alert` devient `callout callout-alert`. Dans `application.css`, remplacer `.flash` par `.callout` dans le sélecteur partagé avec `#error_explanation` / `#confirmation-outcome`, et `.flash-alert` par `.callout-alert`. Vérifier que l'aspect des bandeaux est inchangé à l'écran.
- [x] 1.2 Passer l'assertion `/terminée/` de `test/integration/respondent_forms_test.rb` à `.callout-alert`. Ajouter une assertion `.callout-alert` sur les erreurs du formulaire de campagne invalide. Vérifier avec `bin/rails test test/integration`.

## 2. Partiel de toasts rendu côté serveur

- [x] 2.1 Créer `app/views/layouts/_toasts.html.erb` (design §1) : il ne garde que les clés `notice` / `alert` à valeur textuelle et n'est rendu que s'il y a au moins un message. Il produit la section `aria-live="polite"` `data-turbo-temporary` et, pour chaque message, un toast `flash flash-<type>` avec `role="alert"` pour les alertes, une pastille, le texte et un bouton × nommé « Fermer la notification ».
- [x] 2.2 Remplacer la boucle `flash.each` de `layouts/application.html.erb` et `layouts/respondent.html.erb` par `render "layouts/toasts"`, placé hors de `main`. Vérifier que `.flash-notice` / `.flash-alert` passent toujours dans `campaigns_test.rb`, `respondents_test.rb` et `manager_auth_test.rb` (`bin/rails test`).
- [x] 2.3 Ajouter un test d'intégration : une notice et une alerte sont rendues dans `section.toasts`, hors de `main`, l'alerte avec `role="alert"`, et une clé flash non textuelle (par ex. `timedout: true`) n'est pas affichée. Vérifier avec `bin/rails test`.

## 3. Styles des toasts

- [x] 3.1 Dans `application.css`, ajouter la section « Toasts » (design §2, §6, §8) :
  - colonne en bas à droite au-delà de 40rem, en bas au centre en deçà ;
  - largeurs et marges avec `env(safe-area-inset-*)` ;
  - `pointer-events` comme décrit ;
  - remise à zéro des styles UA de `:popover-open` ;
  - repli `position: fixed` ;
  - carte, pastille et ombre décalée jade ou danger.

  Vérifier à 1400px et à 375px de large, avec JS désactivé : toasts visibles, aucun décalage du contenu, pas de défilement horizontal.
- [x] 3.2 Ajouter les keyframes `toast-in` / `toast-out` (rebond `--bounce`) et la barre de progression `::after` animée sur `--toast-duration`. La pause passe par `:hover`, `:focus-within` et `.toasts.is-paused`, et les alertes n'ont pas de barre. Ajouter la variante `prefers-reduced-motion: reduce` en fondu seul. Vérifier en émulant la réduction des animations dans les DevTools.

## 4. Contrôleur Stimulus `toasts`

- [x] 4.1 Créer `app/javascript/controllers/toasts_controller.js` dans le style des contrôleurs existants, avec un commentaire d'en-tête en français.
  - Au `connect` : poser `popover="manual"`, appeler `showPopover()` si disponible, détacher les toasts et les réinsérer après ≈ 100 ms (design §3) en fixant `--toast-duration` sur les notices (`clamp(4 s, 3 s + 60 ms × caractères, 10 s)`).
  - Au `disconnect` : fermer le popover.

  Vérifier dans le navigateur que la section est dans la couche supérieure (panneau « Top layer » des DevTools Chrome).
- [x] 4.2 Implémenter `dismiss` (classe `is-leaving`, puis retrait à la fin de l'animation), l'action du bouton ×, la fin du minuteur sur `animationend` de la barre, et la classe `is-paused` sur `visibilitychange`. Vérifier :
  - une notice disparaît seule ;
  - elle reste tant qu'on la survole ou qu'elle a le focus, puis repart sur le temps restant ;
  - une alerte ne disparaît jamais seule ;
  - × ferme les deux, au clavier comme à la souris.
- [x] 4.3 Implémenter le balayage avec les Pointer Events, pointeurs `touch` / `pen` uniquement (design §5 : suivi `translateX`, seuil 35 % ou geste rapide, sinon retour en place). Vérifier en émulation tactile des DevTools et sur un vrai téléphone.
- [x] 4.4 Implémenter la limite de 3 toasts, qui retire d'abord la notice la plus ancienne et jamais une alerte. Vérifier dans la console en dupliquant des toasts dans la section.
- [x] 4.5 Ajouter des tests système dans `test/system/` :
  - une notice apparaît puis disparaît d'elle-même ;
  - une alerte (renvoi d'invitation refusé) est toujours là après le délai d'une notice, puis disparaît après un clic sur × ;
  - après la clôture d'une campagne, une autre page puis un retour arrière, « Campagne clôturée. » n'est pas réaffiché.

  Vérifier avec `bin/rails test:system`.

## 5. Vérification d'ensemble

- [x] 5.1 Lancer `bin/rails test` et `bin/rails test:system`. Si le parcours de `feedback_journey_test.rb` est gêné par un toast qui recouvre un bouton, fermer ou attendre le toast dans le test plutôt que de déplacer le toast.
- [x] 5.2 Vérifier à la main sur desktop et sur mobile (Safari iOS ou Chrome Android) :
  - connexion, déconnexion, création, lancement et clôture de campagne, renvoi d'invitation, soumission sondé, rappel « Il manque des notes » ;
  - aucun décalage de la page ;
  - placement correct, barre de geste respectée.
- [x] 5.3 Vérifier les annonces avec un lecteur d'écran (VoiceOver ou NVDA) : la notice au chargement est lue poliment, l'alerte immédiatement, et le focus ne bouge pas. Ajuster le délai de réinsertion si une annonce manque.
