# Proposal

## Why

La marque de la barre du haut est faite de six pastilles colorées posées devant le nom. Elles sont décoratives : elles ne disent rien du produit, et leur seule animation est une vague au survol. Fideback sert à recueillir des retours, donc des échanges entre personnes. Un logo de deux bulles de dialogue, dont une « écrit », le dit sans mot, avec le trait encre, les couleurs et les rebonds qui font déjà le style du site. La bulle de devant passe lentement par les couleurs des voix du site, comme les sondés dans une synthèse. Le choix vient de la maquette « E · Le dialogue » et de sa variante de couleurs « Le chœur ».

## What Changes

- Les six pastilles de la barre du haut sont **remplacées par une marque à deux bulles de dialogue** : une bulle rose derrière, une bulle de devant safran au repos, toutes deux au trait encre, avec trois points dans la bulle de devant. Le nom « Fideback », avec son F à l'ombre rose, reste à côté.
- **Alignement** : le bas de la marque se pose sur la ligne de base de « Fideback » et ne descend plus sous le nom. La marque, haute de 1,25 fois le texte, dépasse au-dessus des lettres ; l'en-tête ne grandit pas.
- **Arrivée animée** : la bulle rose apparaît en rebondissant, puis la bulle de devant. Elle ne se rejoue pas à chaque changement de page, seulement quand la page est chargée.
- **Couleurs des voix** : la bulle de devant passe, en boucle et sans fin, par le safran, le jade, l'azur, l'orchidée et le citron vert, puis revient au safran. La bulle de derrière reste rose.
- **Points de saisie** : les trois points de la bulle de devant pulsent à tour de rôle, en boucle et sans fin, comme une saisie en cours. Seul le mouvement réduit les arrête.
- **Survol** : les deux bulles se balancent, aussi au focus clavier du logo.
- **Mouvement réduit** : aucune animation ; le logo s'affiche immobile, dans son état final, la bulle de devant restant safran.
- **Mobile** : la marque reste visible à côté du nom, bas sur la ligne de base ; sur les très petits écrans elle rétrécit au lieu de disparaître, et l'en-tête tient toujours sur une ligne.
- Le logo est le même dans l'espace des managers et dans celui des sondés.
- L'icône du navigateur (le F encre à l'ombre rose) ne change pas.

## Capabilities

### New Capabilities

(aucune)

### Modified Capabilities
- `brand-wordmark`: la marque de la barre du haut gagne un symbole animé (deux bulles de dialogue) à côté du logotype ; les exigences existantes sur le F et sur le nom d'un seul tenant sont inchangées.

## Impact

- **Vues** : un nouveau partiel `layouts/_brand_mark.html.erb` (SVG en ligne), utilisé par `layouts/application` et `layouts/respondent` à la place des six `<i>`. Le lien du logo porte un petit contrôleur Stimulus qui retient, sur `<html>`, que l'arrivée a eu lieu, pour qu'elle ne se rejoue pas à chaque page.
- **CSS** : `application.css` perd les règles `.brand-dots`, l'animation `hop` et la règle des très petits écrans qui masquait les points ; il gagne les règles de la marque et ses animations.
- **JavaScript** : un contrôleur Stimulus `brand_mark` de quelques lignes.
- **Tests** : intégration (marque présente dans les deux espaces, six pastilles absentes, nom intact), système (états de l'animation, mouvement réduit, mobile, permanence entre deux pages).
- **Documentation** : le paragraphe *Icône* du README et `docs/fonctionnement.md`.
- **Hors périmètre** : l'icône du navigateur et ses versions PNG/ICO, les e-mails, les pages d'erreur statiques de `public/`.
