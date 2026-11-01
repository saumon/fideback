# Design

## Context

- Les deux layouts écrivent la marque à la main : `layouts/application` dans un `link_to root_path, class: "brand"`, `layouts/respondent` dans un `<span class="brand">`. Chacun contient six `<i>` dans `.brand-dots`, plus `<span class="brand-name">Fideback</span>`.
- Le CSS actuel : `.brand-dots` (grille 3 colonnes de pastilles de 0,55 rem), la vague au survol (`.brand:hover .brand-dots i` avec `@keyframes hop`), et, sous 24 rem, `.brand-dots { display: none }` pour que « Créer un compte » et le bouton de menu tiennent avec le logo sur une ligne.
- Le logotype porte déjà le F encre à l'ombre rose (`.brand-name::first-letter`) ; le test `BrandWordmarkTest` vérifie que `.brand-name` est d'un seul tenant et sans élément enfant.
- La règle globale `prefers-reduced-motion` en bas de `application.css` coupe toute animation et toute transition.
- Turbo remplace le `<body>` à chaque visite : tout ce que contient l'en-tête est recréé, donc une animation d'arrivée se rejouerait à chaque page. Le contrôleur `nav_drawer` est déjà conçu pour cette recréation.
- Aujourd'hui `.brand` centre ses éléments (`align-items: center`) : avec une marque de 1,62 em de haut, la queue de la bulle de devant descend d'environ 0,46 em sous la ligne de base du nom (mesuré sur la maquette d'alignement).
- La maquette « E · Le dialogue » fixe le dessin : deux contours de bulle en SVG (`viewBox 0 0 48 40`), rose derrière, trait encre de 2,2, trois points encre dans la bulle de devant. La variante de couleurs « Le chœur » en fait passer la bulle de devant par les voix du site : les couleurs `--saffron`, `--jade`, `--azure`, `--orchid` et `--lime` déjà utilisées pour les sondés d'une synthèse.

## Goals / Non-Goals

**Goals:**
- Un seul endroit pour dessiner la marque, partagé par les deux layouts.
- Un état de repos qui est l'état final : sans animation, le logo est complet.
- Presque pas de JavaScript : un contrôleur de quelques lignes, pour noter que l'arrivée a eu lieu.

**Non-Goals:**
- Pas de nouvelle icône de navigateur ni de nouvelles images binaires : `public/icon.svg` et ses dérivés restent le F encre à l'ombre rose.
- Pas de changement du logotype (nom, F, ombre).
- Pas d'animation du logo au défilement ou à l'inactivité.

## Decisions

### 1. Un partiel SVG en ligne

`layouts/_brand_mark.html.erb` rend le `<svg class="brand-mark" aria-hidden="true" focusable="false">` : deux `<path>` (bulle de derrière `.bubble-back`, bulle de devant `.bubble-front`) et trois `<circle class="typing">` indexés par `--i`. Les couleurs viennent du CSS (`var(--pink)`, `var(--saffron)`, `var(--ink)`, puis les autres voix pour le défilé), pas d'attributs : un changement de thème ne touche que la feuille de style. Les deux layouts le rendent à la place des six `<i>`.

*Écarté :* une image `<img>` ou un fond CSS. Le SVG inline se colore par les tokens du site et s'anime par élément ; une image ne permet ni l'un ni l'autre.

### 2. Le repos est l'état final ; les animations sont ajoutées par-dessus

Les règles de base dessinent la marque complète et immobile, la bulle de devant en safran (`var(--saffron)`), qui est donc la couleur affichée avec un mouvement réduit. Les animations ne sont déclarées que dans `@media (prefers-reduced-motion: no-preference)` : sans cette condition, rien ne bouge, et la règle globale en bas du fichier reste un filet de sécurité. Les animations d'arrivée n'ont qu'un état `from` (échelle zéro), donc elles se terminent sur le dessin de base.

### 3. Une animation par élément

Chaque animation a son propre élément SVG : les deux groupes `.arrive` portent l'arrivée, les deux groupes `.sway` (à l'intérieur) le balancement, la bulle de devant le défilé de couleurs, et chaque point sa pulsation. Aucun élément ne cumule deux animations, donc rien n'est à relancer ou à préserver quand l'une s'ajoute à l'autre.

- Arrivée : `bubble-in` sur la propriété `scale` (de 0, rebond), origine en bas à gauche pour la bulle rose, en bas à droite pour la bulle de devant (qui contient les points), la seconde retardée de 260 ms.
- Couleurs des voix : `voices` sur la propriété `fill` de la bulle de devant, `infinite`, 12 s par tour, cinq couleurs de 2,4 s chacune (safran, jade, azur, orchidée, citron vert), puis retour au safran. Chaque couleur tient 17,5 % du tour et le passage à la suivante dure 2,5 % (0,3 s) : une interpolation lente passerait par des teintes boueuses (du safran au jade, un olive), un passage court les évite.
- Pulsation : `typing` sur chaque point, `infinite`, 1,2 s par cycle après un retard de 700 ms, décalée de 150 ms par point. Son amplitude est faible (le point monte de 2 unités et s'éclaircit). Choix du propriétaire du produit : la pulsation ne s'arrête pas, comme un indicateur de saisie qui reste affiché. Seule la condition `prefers-reduced-motion` la supprime, et le navigateur la suspend de lui-même quand l'onglet est caché.
- Survol et focus (`.brand:is(:hover, :focus-visible)`) : `sway` sur la propriété `rotate`, 520 ms, la bulle de devant retardée de 90 ms.

*Écarté :* un seul élément par bulle, avec une liste d'animations qui s'allonge au survol pour ne pas relancer l'arrivée. Cela repose sur la façon dont le navigateur apparie les animations par nom ; des groupes séparés n'en dépendent pas. Le prototype de la maquette présentait ce défaut (arrivée rejouée après chaque survol).

### 4. L'arrivée n'a lieu qu'une fois par chargement complet

Turbo remplace le `<body>` à chaque visite. Même avec `data-turbo-permanent`, il retire puis remet l'élément conservé, et le navigateur relance alors ses animations CSS : l'arrivée se rejouerait à chaque page (constaté par un test système). Le lien du logo porte donc `data-controller="brand-mark"` : à l'arrivée, le contrôleur attend la fin de `bubble-in` sur la bulle de devant, puis pose `data-brand-arrived` sur `<html>`, que Turbo ne remplace pas. Le CSS n'applique l'arrivée que sous `:root:not([data-brand-arrived])`. Les animations sans fin (couleurs, points) repartent à chaque page sans être visibles comme une arrivée : la bulle de devant reprend le safran et les points repartent.

*Écarté :* `data-turbo-permanent` seul (ne suffit pas, voir ci-dessus), et un état gardé dans `sessionStorage` (plus lourd, et sans lien avec le cycle de vie de la page).

### 5. Mobile : la marque rétrécit au lieu de disparaître

La marque est dimensionnée en `em` à partir de la taille du logotype : 1,25 em de haut et 1,59 em de large (le cadre rogné fait 46,2 × 36,3 unités). Sous 24 rem, elle passe à 1 em de haut et 1,27 em de large, à vérifier à 360 px. Si l'en-tête d'un visiteur ne tient plus sur une ligne à cette largeur, la marque rétrécit encore plutôt que de disparaître.

### 6. Texte et accessibilité

La marque est `aria-hidden="true"` : le lien reste nommé par le texte « Fideback » de `.brand-name`, qui ne change pas. Le focus visible du lien reste celui du site.

### 7. Le bas de la marque sur la ligne de base

`.brand` passe de `align-items: center` à `align-items: baseline`, avec un écart de 0,5 em entre la marque et le nom. Le bas d'un SVG en ligne sert de ligne de base : il se pose donc sur celle du texte. Le `viewBox` est rogné au dessin, trait compris (`0.9 2.9 46.2 36.3` au lieu de `0 0 48 40`) : sans cela, les 0,9 unité vides sous la queue de la bulle laisseraient le dessin au-dessus de la ligne de base. Les origines de transformation (`fill-box`) ne changent pas.

Pour vérifier l'alignement sans toucher au logotype (qui doit rester d'un seul tenant), le test ajoute un élément de taille nulle comme enfant de `.brand` : aligné par la ligne de base, son bas donne la ligne de base du texte.

## Risks / Trade-offs

- [Les points encre doivent rester lisibles sur chaque couleur du défilé] → Les contrastes mesurés vont de 4,4:1 (orchidée) à 9,3:1 (safran), au-dessus de 3:1 pour un élément graphique. Un test système lit la couleur de la bulle à plusieurs instants et vérifie qu'elle change.
- [Deux mouvements permanents dans l'en-tête, la pulsation des points et le défilé de couleurs] → Décision assumée du propriétaire du produit, avec les mêmes atténuations que ci-dessous. Les deux sont coupés ensemble par `prefers-reduced-motion`.
- [Un mouvement permanent dans l'en-tête gêne la lecture, et les critères d'accessibilité demandent normalement une commande de pause pour un mouvement qui dure plus de cinq secondes] → Décision assumée du propriétaire du produit. Atténuations : amplitude faible, mouvement coupé par `prefers-reduced-motion`, suspendu dans un onglet caché. Si une plainte arrive, la limiter à quelques itérations ne change qu'une valeur CSS.
- [Une animation ajoutée au survol relance l'arrivée] → Décision 3 : chaque animation a son propre élément, le survol ne touche donc pas à celle de l'arrivée. Un test système vérifie qu'aucune arrivée ne tourne après un survol suivi d'une sortie.
- [L'arrivée se rejoue à chaque page par une réinsertion de l'élément par Turbo] → Décision 4 : le marqueur sur `<html>`, vérifié par un test système qui navigue d'une page à l'autre.
- [Un en-tête de visiteur trop étroit à 360 px] → La marque rétrécit (décision 5) ; un test système à 360 px et à 380 px vérifie que les éléments sont sur une ligne.
- [Navigateurs sans les propriétés `scale` et `rotate` individuelles] → Elles sont prises en charge par les navigateurs actuels ; sans elles, les bulles restent immobiles et la marque garde son état final.
- [La marque, posée sur la ligne de base, dépasse au-dessus des lettres et pourrait agrandir l'en-tête] → Posée sur la ligne de base, le bloc logo mesure 1,53 em de haut (mesuré dans la maquette d'alignement), contre 1,62 em avec le centrage actuel : l'en-tête ne grandit pas. Un test système compare les hauteurs.
- [L'alignement sur la ligne de base d'un SVG dans un conteneur flex diffère selon les navigateurs] → Le bas d'un élément remplacé sert de ligne de base, ce que tous les navigateurs actuels appliquent ; un test mesure l'écart à 380, 360 et en pleine largeur.

## Migration Plan

Aucune donnée ni migration. Déploiement ordinaire ; retour arrière par `git revert`, les pastilles revenant avec leur CSS.
