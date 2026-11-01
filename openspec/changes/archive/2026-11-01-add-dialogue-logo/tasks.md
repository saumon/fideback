# Tasks

## 1. Marque dans les deux espaces

- [x] 1.1 Créer le partiel `layouts/_brand_mark.html.erb` (SVG `aria-hidden` au `viewBox` rogné `0.9 2.9 46.2 36.3` : bulle rose, bulle de devant, trois points indexés), le rendre dans `layouts/application` et `layouts/respondent` à la place des six `<i>`, donner au lien du logo `id="brand"` et `data-controller="brand-mark"`, et vérifier par un test d'intégration : marque présente dans les deux espaces, `.brand-dots` absent, nom `Fideback` intact et sans enfant

## 2. Style et animations

- [x] 2.1 Remplacer dans `application.css` les règles `.brand-dots`, `hop` et la règle des très petits écrans par le style de la marque (formes, trait encre, bulle de derrière rose, bulle de devant safran, 1,25 em de haut) et passer `.brand` à `align-items: baseline` avec 0,5 em d'écart, puis vérifier à 1400 px que le bas de la marque est sur la ligne de base et que le logo est complet et immobile sans animation
- [x] 2.2 Ajouter, dans `@media (prefers-reduced-motion: no-preference)`, l'arrivée (`bubble-in`, la bulle safran retardée), la pulsation sans fin des points (`typing`, `infinite`) le défilé des couleurs de la bulle de devant (`voices`, `infinite`, cinq voix en 12 s) et le balancement au survol et au focus (`sway`, sur un groupe distinct de celui de l'arrivée), l'arrivée n'étant appliquée que sous `:root:not([data-brand-arrived])`, et créer le contrôleur Stimulus `brand_mark` qui pose `data-brand-arrived` sur `<html>` à la fin de l'arrivée, et vérifier par un test système : états pendant l'arrivée, pulsation toujours en cours après plusieurs secondes, couleur de la bulle de devant différente à deux instants espacés de quelques secondes, aucune animation d'arrivée ni de défilé relancée après un survol suivi d'une sortie
- [x] 2.3 Dimensionner la marque sur petit écran : 1,25 em de haut en dessous de 40 rem, 1 em en dessous de 24 rem, sans masquage, et vérifier à 380 px et à 360 px que le bas de la marque est sur la ligne de base et que le logo, « Créer un compte » et le bouton de menu sont sur une ligne

## 3. Tests système

- [x] 3.1 Créer `test/system/brand_mark_test.rb` : marque visible dans les deux espaces, arrivée jouée au chargement, pulsation encore en cours après plusieurs secondes et pendant un survol, balancement au survol et au focus clavier, mouvement réduit émulé sans aucune animation sur la marque et bulle de devant restant safran, arrivée non rejouée après une navigation Turbo, bas de la marque à moins d'un pixel de la ligne de base du texte (mesurée avec un élément de taille nulle ajouté comme enfant de `.brand`) en pleine largeur, à 380 px et à 360 px, en-tête pas plus haut qu'avec les six pastilles, en-tête sur une ligne à 380 px et à 360 px
- [x] 3.2 Lancer `bin/rails test:system` en entier et vérifier qu'il passe, en rejouant deux fois les tests de cet ensemble pour repérer une instabilité

## 4. Documentation et vérifications

- [x] 4.1 Mettre à jour le paragraphe *Icône* du README (le logo de la barre du haut contient la marque à bulles, dans `layouts/_brand_mark`, en plus du F du logotype) et ajouter une phrase à `docs/fonctionnement.md`, puis vérifier que les liens du README fonctionnent
- [x] 4.2 Vérifier avec `openspec validate add-dialogue-logo --strict`, puis `bin/rails test`, `bin/rubocop`, `bin/rails test:system` et `bin/ci` au vert

## Workflow follow-up

- Archiver le changement avec `/opsx:archive` (synchronisation vers `brand-wordmark`), puis réécrire le Purpose de `brand-wordmark` pour qu'il couvre la marque à bulles en plus du logotype, et terminer avec `/saumon-finish`.
