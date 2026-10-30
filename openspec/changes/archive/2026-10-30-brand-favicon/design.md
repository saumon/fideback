# Design

## Context

- `public/icon.svg` et `public/icon.png` sont le rond rouge par défaut de Rails.
- `layouts/application.html.erb` déclare `icon.png`, `icon.svg` et `apple-touch-icon` vers `/icon.png`.
- `layouts/respondent.html.erb` ne déclare aucune icône.
- Les pages d'erreur statiques (`public/400.html`, `404`, `406-unsupported-browser`, `422`, `500`) n'ont pas de lien d'icône, et `public/favicon.ico` n'existe pas.
- Le manifeste PWA (`app/views/pwa/manifest.json.erb`) référence `icon.png`, mais ses routes sont commentées : il n'est pas servi.
- La machine n'a ni ImageMagick, ni rsvg, ni Inkscape. En revanche, `selenium-webdriver` (groupe de test) et Chrome headless servent déjà aux tests système.
- Le dessin a été validé sur maquette : un F tracé en trois rectangles arrondis, et son ombre rose décalée de 3 unités sur une grille de 32.

## Goals / Non-Goals

**Goals:**
- Un seul dessin source, celui de la maquette validée, décliné en fichiers par plateforme.
- Des fichiers binaires (PNG, ICO) régénérables par un script, sans nouvelle dépendance.

**Non-Goals:**
- Activer la PWA ou corriger les couleurs du manifeste.
- Animer l'icône.

## Decisions

### 1. Le SVG de la maquette, avec sa variante sombre intégrée

`public/icon.svg` reprend tel quel le dessin validé (viewBox 32×32) :

```svg
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32">
  <style>@media (prefers-color-scheme: dark) { .letter { fill: #F7F5FC } }</style>
  <g fill="#FF5D8F" transform="translate(3 3)">  <!-- ombre -->
    <rect x="6" y="2" width="7" height="24" rx="1.5"/>
    <rect x="6" y="2" width="17" height="7" rx="1.5"/>
    <rect x="6" y="12.5" width="14" height="6" rx="1.5"/>
  </g>
  <g class="letter" fill="#231942">                  <!-- F -->
    …mêmes trois rectangles…
  </g>
</svg>
```

La règle `prefers-color-scheme` vit dans le SVG lui-même. Chrome et Firefox l'évaluent selon le thème du système. Safari n'affiche pas les favicons SVG : il prend le PNG, qui garde le F encre.

*Écarté :* deux fichiers SVG choisis par `<link rel="icon" media="(prefers-color-scheme: dark)">`. La prise en charge de l'attribut `media` sur les icônes est inégale, et il faudrait maintenir deux fichiers.

### 2. Les fichiers et leurs rôles

| Fichier | Contenu | Utilisé par |
|---|---|---|
| `public/icon.svg` | dessin + variante sombre, transparent | `<link rel="icon" type="image/svg+xml">` |
| `public/icon.png` | 512×512, F encre, transparent | `<link rel="icon" type="image/png">`, Safari, manifeste |
| `public/apple-touch-icon.png` | 180×180, F encre sur fond `#F7F5FC` plein | `<link rel="apple-touch-icon">`, et requête implicite d'iOS à cette adresse |
| `public/favicon.ico` | ICO contenant des PNG 16, 32 et 48 px, F encre, transparent | `/favicon.ico` demandé implicitement par les navigateurs |

Pour l'icône iOS, le fond plein couvre tout le carré, sans coins arrondis : iOS applique son propre masque. Le F est réduit à environ 70 % du carré pour garder une marge.

### 3. Génération par `script/icons`, avec Chrome headless

Le script Ruby `script/icons` :
- démarre Chrome headless avec `selenium-webdriver` ;
- charge chaque source SVG dans une page vide ;
- la dessine sur un `<canvas>` aux tailles voulues, avec un fond plein pour l'icône iOS ;
- récupère les PNG par `toDataURL`, sans capture d'écran, donc avec une transparence exacte et des dimensions au pixel près ;
- assemble `favicon.ico` en Ruby pur : en-tête ICO plus les trois PNG, format accepté par tous les navigateurs depuis Windows Vista.

Les sources sont `public/icon.svg` et une source dérivée pour l'icône iOS, générée par le script en ajoutant le rectangle de fond. Il n'y a qu'un seul dessin à maintenir.

Le script se lance avec `bin/rails runner script/icons` ou `ruby script/icons`, au choix lors de l'implémentation. Les binaires produits sont commités : ils ne sont pas générés au build ni au déploiement.

*Écarté :* ajouter `mini_magick` ou `ruby-vips`. Ce serait une dépendance système de plus pour une opération ponctuelle.

*Écarté :* des PNG faits à la main. Ils deviendraient impossibles à régénérer si le dessin change.

### 4. Liens dans les layouts et les pages d'erreur

- **`layouts/application.html.erb`** : garder `icon.png` et `icon.svg`, et pointer `apple-touch-icon` vers `/apple-touch-icon.png`.
- **`layouts/respondent.html.erb`** : ajouter les trois mêmes liens. Ils sont écrits en dur, comme dans le layout manager, plutôt que dans un partiel partagé, car ce ne sont que trois lignes.
- **Pages d'erreur statiques** : ajouter `<link rel="icon" href="/icon.svg" type="image/svg+xml">` et `<link rel="icon" href="/icon.png" type="image/png">`. Ces pages sont servies sans layout Rails.

## Risks / Trade-offs

- **Cache agressif des favicons** : après déploiement, des navigateurs peuvent garder le rond rouge un moment. → Ce n'est pas bloquant. Pour vérifier, recharger sans cache ou ouvrir une fenêtre privée. Pas de paramètre de version dans l'URL : il faudrait le maintenir à chaque changement de l'icône.
- **Safari et le thème sombre** : le PNG garde le F encre, peu visible sur un onglet sombre de Safari. → C'est une limite assumée de la plateforme. L'ombre rose reste visible et la maquette a montré une lisibilité correcte.
- **Le script dépend de Chrome**, installé par Selenium Manager comme pour les tests système. → Il n'est lancé qu'à la main, après une modification du dessin. Il est documenté dans le README.
- **Le manifeste reste rouge** (`theme_color`, `background_color`). → Il n'est pas servi tant que la PWA est désactivée ; c'est noté hors périmètre dans la proposition.
