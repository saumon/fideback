## 1. Route et contrôleur

- [x] 1.1 Ajouter `resources :users, only: :index` dans le namespace `admin` de `config/routes.rb`
- [x] 1.2 Créer `Admin::UsersController#index` (hérite d'`Admin::BaseController`) qui charge les managers par `created_at` puis `id` décroissants

## 2. Vues et styles

- [x] 2.1 Créer `app/views/admin/users/index.html.erb` : titre « Utilisateurs », lien de retour vers l'administration, tableau nom / e-mail / rôle / inscription dans `.table-scroll`
- [x] 2.2 Afficher le badge « Non confirmé » pour les comptes sans `confirmed_at`, et le libellé de rôle « Admin » / « Manager »
- [x] 2.3 Ajouter les styles du tableau et du badge dans `application.css` (couleurs du thème, `prefers-reduced-motion` respecté)
- [x] 2.4 Remplacer le message vide de `app/views/admin/dashboard/show.html.erb` par le bouton « Utilisateurs » menant à `admin_users_path`

## 3. Tests

- [x] 3.1 Tests d'intégration de l'écran : Admin (200, titre), manager non Admin (404), visiteur (redirection vers la connexion)
- [x] 3.2 Tests du contenu : chaque manager listé avec nom, e-mail, rôle et date ; badge « Non confirmé » présent seulement pour un compte non confirmé ; ordre par inscription décroissante ; aucun formulaire ni bouton d'action
- [x] 3.3 Mettre à jour `test/integration/admin_area_test.rb` : le bouton « Utilisateurs » est présent sur `/admin`, sans formulaire

## 4. Vérification

- [x] 4.1 Lancer `bin/rails test` et `bin/rubocop`, puis `bin/ci` avant fusion
