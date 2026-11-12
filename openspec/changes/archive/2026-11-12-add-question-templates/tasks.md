# Tasks

## 1. Modèles de données

- [x] 1.1 Migration créant `question_templates` (`manager_id` NULL, FK `ON DELETE CASCADE`, `name`, `system`) et `question_template_items`, avec la ligne système et ses quatre questions ; vérifier avec `bin/rails db:migrate` puis `db:rollback`/`db:migrate` et que `db/schema.rb` est à jour
- [x] 1.2 Modèles `QuestionTemplate` et `QuestionTemplateItem` : nom obligatoire, au moins un item, note et/ou commentaire, renumérotation des positions, scope `available_to(manager)`, modèle système non modifiable ni supprimable ; vérifier par des tests de modèle (cas valides, invalides, système protégé)
- [x] 1.3 `Manager has_many :question_templates, dependent: :destroy`, fixtures (modèle système, modèles de deux managers) ; vérifier par un test de suppression de compte conservant le modèle système

## 2. Gestion des modèles

- [x] 2.1 Routes `resources :question_templates, path: "modeles"` et `QuestionTemplatesController` (index, show, new, create, edit, update, destroy) limité au scope du manager, avec refus sur le modèle système ; vérifier par des tests d'intégration (CRUD, 404 sur le modèle d'un autre manager, refus sur le système)
- [x] 2.2 Vues index, show, formulaire à lignes imbriquées (réutilise `_nested_rows` et un partial de ligne), suppression avec `confirm-dialog`, en français et dans le style de l'application ; vérifier par des tests de vues/intégration et visuellement avec `/run`
- [x] 2.3 Entrée « Mes modèles » dans la navigation et section `:templates` dans `current_nav_section` ; vérifier par `main_navigation_test` (page courante sur liste, création, modification après erreur, absente hors connexion)

## 3. Sélection à la création de campagne

- [x] 3.1 Remplacer `Campaign::DEFAULT_QUESTIONS` et `build_default_questions` par une construction depuis un modèle ; `CampaignsController#new` choisit le modèle (défaut si absent ou hors scope) ; vérifier par des tests d'intégration sur `new` avec et sans `template_id`, avec un identifiant étranger ou inconnu
- [x] 3.2 Sélecteur de modèle dans le formulaire (création uniquement), `turbo-frame` autour des questions et contrôleur Stimulus déclenchant le chargement au changement ; vérifier par un test système : le choix remplace les questions, le nom et les contacts saisis sont conservés
- [x] 3.3 Conserver le choix et les questions saisies après un `create` refusé, et ne pas afficher le sélecteur à l'édition ; vérifier par des tests d'intégration (réaffichage, édition) et le test de campagne enregistrée sans lien avec le modèle modifié ensuite

## 4. Finitions

- [x] 4.1 Mettre à jour le README si les fonctionnalités y sont listées, et lancer `bin/ci` ; vérifier que tout passe, puis `bin/rails test:system`
