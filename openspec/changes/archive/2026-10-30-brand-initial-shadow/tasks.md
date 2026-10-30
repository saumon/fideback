# Tasks

## 1. Initiale du logotype

- [x] 1.1 Dans `layouts/application.html.erb` et `layouts/respondent.html.erb`, envelopper le texte « Fideback » du logotype dans `<span class="brand-name">Fideback</span>`, sans couper le mot (design §1). Vérifier dans le HTML rendu que le mot reste un seul nœud texte.
- [x] 1.2 Dans `application.css`, à côté de `.brand`, ajouter `.brand-name { display: inline-block; }` et `.brand-name::first-letter { text-shadow: 0.05em 0.05em 0 var(--pink); margin-right: 0.06em; }` (design §1 et §2). Vérifier dans le navigateur que seul le F porte l'ombre rose et que le F reste encre au survol du lien.
- [x] 1.3 Ajuster le décalage à l'œil, sans que le rose touche le « i » (retenu : 0,05 em), en comparant la barre et l'onglet côte à côte. Vérifier que les deux se lisent comme la même marque.
- [x] 1.4 Ajouter un test d'intégration, à côté de `test/integration/app_icon_test.rb` : la page d'accueil et le formulaire d'un sondé contiennent `.site-header .brand .brand-name` avec exactement le texte « Fideback ». Vérifier avec `bin/rails test`.

## 2. Vérification d'ensemble

- [x] 2.1 Lancer `bin/rails test`, `bin/rails test:system` et `bin/rubocop`, et vérifier que tout passe.
- [x] 2.2 Vérifier à la main, dans l'espace des managers et dans celui des sondés :
  - le F est encre avec son ombre rose ;
  - les pastilles sautent toujours au survol ;
  - le logotype ne passe pas à la ligne sur un écran de téléphone ;
  - la recherche « Fideback » dans la page trouve le logotype.
