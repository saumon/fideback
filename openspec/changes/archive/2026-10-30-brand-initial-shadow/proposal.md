# Proposal

## Why

Depuis le nouveau favicon, l'onglet montre un « F » encre avec une ombre rose pleine, décalée vers le bas à droite. Dans la barre du haut, le logotype « Fideback » est écrit d'une seule couleur, sans ce rappel. L'onglet et la page ne se répondent pas, alors que la marque doit être la même aux deux endroits.

## What Changes

- Dans le logotype de la barre du haut, le « F » initial reprend le style du favicon : lettre encre (`--ink`), ombre rose (`--pink`) pleine et nette, décalée vers le bas à droite, proportionnée à la taille du texte.
- Le reste du mot (« ideback ») et les pastilles colorées qui précèdent le mot ne changent pas.
- Le style s'applique aux deux barres qui affichent le logotype : l'espace des managers et l'espace des sondés.
- Le nom accessible du lien reste « Fideback ». Un lecteur d'écran ne doit pas lire « F » et « ideback » séparément.

Hypothèses retenues, à corriger si besoin :
- « Même style » signifie même couleur et même ombre. Le F garde la police du logotype, Bricolage Grotesque. Il n'est pas remplacé par le dessin géométrique en rectangles de l'icône.
- L'application n'a pas de thème sombre : la variante claire du F, propre au favicon, ne s'applique pas ici.

## Capabilities

### New Capabilities
- `brand-wordmark` : le logotype « Fideback » affiché dans la barre du haut, son apparence, sa cohérence avec l'icône de l'application et son accessibilité.

### Modified Capabilities

Aucune. Les exigences de `app-icon` portent sur les fichiers d'icône et restent inchangées.

## Impact

- Vues : `app/views/layouts/application.html.erb` et `app/views/layouts/respondent.html.erb`. Le mot « Fideback » du logotype est enveloppé dans un élément dédié.
- Styles : `app/assets/stylesheets/application.css`, avec une règle pour l'initiale du logotype à côté de `.brand`.
- Tests : une vérification de la présence du logotype stylable dans les deux layouts.
- Aucun changement de dépendance, de route ni de fichier d'icône.
- Hors périmètre : animer le F au survol, modifier le favicon, ajouter un thème sombre à l'application.
