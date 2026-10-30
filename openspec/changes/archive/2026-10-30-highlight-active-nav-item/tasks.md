## 1. Section courante

- [x] 1.1 Ajouter `current_nav_section` dans `ApplicationHelper` : associer `controller_path` à `:campaigns`, `:team`, `:admin`, `:account`, `:sign_in`, ou `nil`
- [x] 1.2 Ajouter le helper `nav_link(label, path, section)` qui pose `aria-current="page"` sur l'entrée de la section courante

## 2. Navigation et style

- [x] 2.1 Remplacer les `link_to` de la navigation dans `app/views/layouts/application.html.erb` par `nav_link` (Mes campagnes, Mon équipe, Administration, nom du manager, Se connecter) ; « Créer un compte » reste un bouton
- [x] 2.2 Styler `nav a[aria-current="page"]` dans `application.css` : gras et barre multicolore en `::after` qui se déroule (`scaleX`), sans décalage des liens voisins
- [x] 2.3 Vérifier que la règle globale `prefers-reduced-motion` de `application.css` supprime déjà la transition de la barre, sinon l'ajouter
- [x] 2.4 Augmenter l'espacement vertical du menu pour que la barre ne touche pas la ligne suivante quand le menu passe à la ligne

## 3. Tests

- [x] 3.1 Tests d'intégration de `aria-current` : Mes campagnes (liste, création, détail, édition, synthèse), Mon équipe, Administration (écran et utilisateurs), compte (affichage et mise à jour refusée), Se connecter ; une seule entrée signalée à la fois
- [x] 3.2 Tests des cas sans entrée signalée : page introuvable, espace sondé, création de compte
- [x] 3.3 Vérifier que les tests existants sur les liens du menu (équipe, administration, 404) passent toujours

## 4. Vérification

- [x] 4.1 Contrôler dans un navigateur le rendu de la barre sur bureau et sur écran étroit (menu sur deux lignes), avec et sans mouvement réduit
- [x] 4.2 Lancer `bin/rails test`, `bin/rubocop`, puis `bin/ci` avant fusion

## 5. Animations de la barre

- [x] 5.1 Remplacer la transition de la barre par une animation d'ouverture (`scaleX` de 0 à 1, rebond) jouée à l'affichage du lien actif
- [x] 5.2 Ajouter la boucle : dégradé fermé sur sa couleur de départ, `background-size: 200%`, défilement continu de `background-position`
- [x] 5.3 Vérifier que, sous `prefers-reduced-motion`, la barre reste complète et immobile ; contrôler l'ouverture et la boucle dans un navigateur
- [x] 5.4 Relancer `bin/rails test`, `bin/rubocop` et `bin/ci`
