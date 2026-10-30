# Design

## Context

- Le logotype est écrit en dur dans deux layouts :
  - `layouts/application.html.erb` : `<a class="brand">` contenant `.brand-dots`, puis le texte « Fideback » ;
  - `layouts/respondent.html.erb` : `<span class="brand">` avec la même structure.
- `.brand` est en `display: inline-flex`. Le texte « Fideback » y forme un élément flex anonyme.
- La police est Bricolage Grotesque, en 1.5rem, graisse 800, `font-stretch: 80%`, couleur `--ink`.
- `public/icon.svg` décale l'ombre de 3 unités pour un F de 24 unités de haut, soit 1/8 de la hauteur de la lettre. Une capitale de Bricolage mesure environ 0,7 em, ce qui donne un décalage d'environ 0,09 em.
- Les boutons utilisent déjà des ombres pleines (`box-shadow: 3px 3px 0`). L'application n'a pas de thème sombre.

## Goals / Non-Goals

**Goals:**
- Un style d'initiale unique, défini une fois en CSS et partagé par les deux layouts.
- Un décalage relatif à la taille du texte, pour garder les proportions de l'icône si la taille du logotype change.

**Non-Goals:**
- Reproduire le dessin en rectangles du favicon dans la barre.
- Animer l'initiale au survol. Les pastilles gardent leur saut actuel.

## Decisions

### 1. `::first-letter` sur un élément qui enveloppe le mot

Le texte devient `<span class="brand-name">Fideback</span>`, avec la règle suivante :

```css
.brand-name { display: inline-block; }
.brand-name::first-letter { text-shadow: 0.05em 0.05em 0 var(--pink); margin-right: 0.06em; }
```

`::first-letter` ne s'applique pas à un conteneur flex. Il s'applique en revanche à un élément `inline-block`, qui devient un élément flex de `.brand`. Le mot reste un seul nœud texte, ce qui satisfait l'exigence « Nom du logotype intact » sans `aria-label`.

*Écarté :* `<span>F</span>ideback`. Certains lecteurs d'écran, VoiceOver notamment, annoncent alors deux morceaux. Il faudrait ajouter un `aria-label` sur le lien, mais le `<span class="brand">` des sondés n'est pas interactif, et un `aria-label` y est ignoré.

*Écarté :* une image SVG du F. Elle ferait perdre la police du logotype et créerait une deuxième source du dessin à maintenir.

### 2. `text-shadow` plein en `em`

`text-shadow: 0.05em 0.05em 0 var(--pink)` : flou nul, comme l'ombre du favicon et celles des boutons, avec un décalage relatif à la police. La couleur de la lettre reste celle héritée de `.brand` (`--ink`), et le hover de `a.brand` la garde déjà encre.

L'initiale reçoit aussi `margin-right: 0.06em`. Avec l'interlettrage serré du logotype (`-0.02em`), le « i » recouvrait sinon le bord droit de l'ombre, que le favicon montre en entier.

*Écarté :* un décalage en `px`. Il ne suit pas la taille du texte, alors que le favicon est défini en proportion.

## Risks / Trade-offs

- **Prise en charge de `::first-letter` avec `text-shadow`** : elle est assurée par tous les navigateurs courants. Dans le pire des cas, le F s'affiche sans ombre, ce qui n'a pas de conséquence fonctionnelle.
- **Valeur exacte du décalage** : le calcul donnait 0,09 em, mais le rose touchait alors le « i ». → Ramené à 0,05 em après vérification à l'œil. Un blanc net sépare maintenant le rose du « i ». En contrepartie, l'ombre est un peu plus discrète que sur l'icône.
- **Lecture de l'ombre sur fond clair** : le rose `#FF5D8F` sur `--bg` `#F7F5FC` est décoratif et n'a pas d'exigence de contraste. La lettre encre reste parfaitement lisible.
