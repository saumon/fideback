# Tasks

## 1. Rôle et attribution

- [x] 1.1 Ajouter la migration `managers.role` (chaîne, `NOT NULL`, défaut `manager`) qui promeut le manager le plus ancien (`created_at`, puis `id`), avec `down` ; vérifier que `db/schema.rb` est à jour et que la migration passe sur une base vide et sur une base à plusieurs managers
- [x] 1.2 Déclarer l'enum `role` dans `Manager` (`manager`, `admin`) et poser `admin` dans un `before_create` lorsque `Manager.none?` ; vérifier par des tests de modèle : première création admin, suivantes manager, après suppression de l'Admin (d'autres managers restant) le nouveau est manager, deux créations enchaînées donnent un seul Admin
- [x] 1.3 Tester la migration dans `test/db/` sur le modèle de `backfill_contacts_from_campaigns_test.rb` : le plus ancien devient admin, les autres manager, base vide sans erreur
- [x] 1.4 Vérifier par un test d'intégration dans `test/integration/manager_auth_test.rb` que la première inscription crée un compte `admin` non activé, puis qu'une inscription suivante crée un `manager`

## 2. Espace d'administration

- [x] 2.1 Ajouter `Admin::BaseController` (404 pour un non-admin connecté, redirection vers la connexion pour un anonyme), `Admin::DashboardController#show`, la route `/admin` et la vue titrée « Administration » sans action ; vérifier par des tests d'intégration : Admin 200, manager 404, anonyme redirigé
- [x] 2.2 Ajouter le lien « Administration » dans la navigation du layout, visible seulement pour un Admin connecté ; vérifier par des tests d'intégration : présent pour l'Admin et mène à `/admin`, absent pour un manager et pour un visiteur
- [x] 2.3 Habiller l'écran selon le style du projet (coloré, original, animé), vérifier dans le navigateur sur ordinateur et à 360 px de large, et ajuster les fixtures de `test/fixtures/managers.yml` pour disposer d'un Admin et d'un manager

## 3. Vérification d'ensemble

- [x] 3.1 Lancer toute la suite (`bin/rails test`) et `bin/rubocop`, puis parcourir à la main : base neuve, première inscription, activation, connexion, lien « Administration », 404 avec un second compte
