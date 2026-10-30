# Tasks

## 1. Chemin d'erreur dynamique

- [x] 1.1 Ajouter `ErrorsController#not_found` (sans authentification, format HTML forcé, statut 404, layout `respondent` pour les adresses `/repondre...`), la route `match "/404", via: :all` et `config.exceptions_app` enveloppée avec repli sur `public/404.html` ; vérifier par des tests d'intégration : adresse inconnue, `.json` inconnu, enregistrement absent (`find_by!`) et méthode POST répondent 404 avec la page habillée
- [x] 1.2 Faire rendre la page par `Admin::BaseController` au lieu de lever `RoutingError` ; vérifier que `test/integration/admin_area_test.rb` passe et affiche la page habillée pour un non-Admin
- [x] 1.3 Tester le repli : simuler un échec du rendu et vérifier que `public/404.html` est servie avec le statut 404 ; vérifier que la navigation d'un manager connecté (« Mes campagnes ») est présente sur une 404, sinon documenter le repli visiteur dans le test

## 2. La page

- [x] 2.1 Écrire la vue `errors/not_found` : « 404 » en chiffres colorés, titre, chapeau, carte « Synthèse : cette page » à trois voix, lien de retour (campagnes pour un manager connecté, accueil sinon, aucun lien de compte sous `/repondre`) ; vérifier par des tests d'intégration : texte « 404 » et titre présents, bon lien de retour pour chaque cas, pas de lien « Créer un compte » ni « Se connecter » sous `/repondre`
- [x] 2.2 Ajouter les styles `.page-errors` dans `application.css` (réutiliser variables, `--bounce`, ombre décalée, rotation de la carte) avec éléments décoratifs en `aria-hidden` ; vérifier à l'œil sur ordinateur et à 360 px de large, en thème clair, avec et sans « réduire les animations » du système
- [x] 2.3 Ajouter la route de développement `/dev/404`, documenter dans le README qu'elle prévisualise la page et que `public/404.html` est le secours ; vérifier que l'adresse s'ouvre en développement

## 3. Vérification d'ensemble

- [x] 3.1 Lancer `bin/rails test` et `bin/rubocop` ; parcourir à la main en développement : `/dev/404`, `/admin` avec un manager non Admin, une adresse inconnue, un lien de sondé inconnu
