# Design

## Context

Les questions d'une campagne sont déjà des enregistrements `Question` propres à la campagne, édités par `accepts_nested_attributes_for` avec le contrôleur Stimulus `nested-form`. Le jeu initial vient de la constante `Campaign::DEFAULT_QUESTIONS`, appliquée par `build_default_questions` dans `CampaignsController#new`. L'annuaire (`resource :team`) donne le précédent d'une ressource privée au manager. Le style de l'interface (français, coloré, animé) suit le skill `project-conventions`.

## Goals / Non-Goals

**Goals:**
- Garder l'enregistrement d'une campagne inchangé : seul l'affichage initial des questions dépend du modèle.
- Réutiliser au maximum le partial `_question_fields`, `_nested_rows` et la validation « note et/ou commentaire ».

**Non-Goals:**
- Enregistrer les questions d'une campagne comme nouveau modèle.
- Modèle par défaut modifiable, par manager ou par l'Admin.
- Lien persistant entre une campagne et son modèle, versionnage, statistiques d'usage.
- Partage de modèles entre managers.

## Decisions

**1. Deux tables : `question_templates` et `question_template_items`.**
`question_templates(manager_id NULL, name, system boolean)` et `question_template_items(question_template_id, position, prompt, rating, comment)`. Alternative écartée : réutiliser `questions` avec un `campaign_id` nullable, qui fragiliserait les contraintes et les requêtes existantes (réponses, synthèses). Les items dupliquent les quatre colonnes de `Question` ; la duplication est faible et évite tout couplage. La validation « note et/ou commentaire » est partagée via un concern.

**2. Modèle système : une ligne en base, `manager_id` NULL et `system: true`.**
Créée par la migration sous le nom « Modèle par défaut », qui reprend le contenu de la constante, laquelle est supprimée. Alternative écartée : garder la constante et l'injecter dans la liste, ce qui ferait deux sources de vérité et un « faux » modèle aux comportements particuliers. Le modèle système est protégé dans le modèle (modification et destruction refusées) et dans le contrôleur. Les tests prennent leur modèle système dans les fixtures et non dans la migration.

**3. Portée d'un manager : `current_manager.question_templates` plus le modèle système.**
Un scope `QuestionTemplate.available_to(manager)` sert à la liste et au sélecteur. Les recherches par identifiant passent par ce scope, d'où un 404 pour le modèle d'un autre manager. `has_many :question_templates, dependent: :destroy` sur `Manager` ; la clé étrangère `manager_id` est protégée par `ON DELETE CASCADE` sans toucher la ligne système. Le tri : modèle système en premier, puis les modèles du manager par nom.

**4. Ressource `resources :question_templates, path: "modeles"`.**
CRUD classique avec formulaire à lignes imbriquées calqué sur celui des questions de campagne. Le détail du modèle système est un `show` en lecture seule. La suppression passe par la modale `confirm-dialog` existante. La navigation reçoit « Mes modèles » et `current_nav_section` renvoie `:templates` pour ce contrôleur.

**5. Sélection : Turbo Frame et contrôleur Stimulus.**
Dans le formulaire de campagne, un `<select name="template_id">` hors des paramètres `campaign` (il n'est donc pas soumis avec la campagne), placé avant le fieldset des questions. Au `change`, un petit contrôleur Stimulus fait un GET `campaigns/new?template_id=X` ciblant un `<turbo-frame id="questions">` qui enveloppe la liste de questions et son `<template>`. `CampaignsController#new` choisit le modèle (défaut si absent ou inconnu) et n'affiche que le frame quand la requête vient de lui. Alternatives écartées : rechargement complet (perte de saisie) et JSON plus rendu JS (duplique le rendu des lignes). L'écrasement est sans confirmation, par décision. Le sélecteur est libellé « Partir d'un modèle », avec l'aide « Choisir un modèle remplace les questions ci-dessous. » ; ses options sont le « Modèle par défaut » puis, dans un `<optgroup label="Mes modèles">` affiché seulement si le manager en a, ses modèles par ordre alphabétique.

**6. Conservation après erreur de validation.**
`create` réaffiche le formulaire avec les questions soumises. Le sélecteur reste sur le modèle choisi (`template_id` repassé en paramètre de rendu), sans relancer de requête au chargement : seul l'événement `change` utilisateur déclenche le chargement.

**7. Copie à la création.**
`CampaignsController#new` construit `campaign.questions` à partir des items du modèle (`build_questions_from(template)`), remplaçant `build_default_questions`. Au `create`, rien ne change : les `questions_attributes` soumis sont enregistrés tels quels.

## Risks / Trade-offs

- [Perte de saisie des questions au changement de modèle] → voulu : écrasement sans confirmation ; le sélecteur n'agit que sur le frame des questions, le reste du formulaire reste intact.
- [Valeurs absentes ou piratées dans `template_id`] → repli sur le modèle par défaut ; un identifiant hors du scope du manager ne révèle rien.
- [Migration en production] → elle crée une seule ligne et ses items ; elle est idempotente (recherche par `system: true`). Retour arrière : la migration inverse supprime la ligne système puis les tables.
- [Un modèle supprimé pendant que le formulaire d'une campagne est ouvert] → sans effet : les questions déjà affichées sont dans le formulaire, qui ne référence pas le modèle.
