# Tasks

## 1. Modèle de données

- [x] 1.1 Ajouter la migration de schéma : table `contacts` (`manager_id`, `name`, `email`, `managed`, `surveyable`, index unique `(manager_id, email)`), puis `contact_id` facultatif sur `subjects` et `respondents` (FK `on_delete: :nullify`, index unique `(campaign_id, contact_id)`). Vérification : `bin/rails db:migrate` puis `db:rollback` puis `db:migrate` passent, et `db/schema.rb` est à jour.
- [x] 1.2 Créer le modèle `Contact` (normalisation de l'e-mail, présence, format, unicité par manager insensible à la casse, au moins un rôle) et les associations `Manager has_many :contacts`, `Subject` / `Respondent belongs_to :contact, optional: true`. Vérification : tests de modèle `test/models/contact_test.rb` sur doublon, casse, e-mail invalide et absence de rôle.
- [x] 1.3 Ajouter les fixtures `contacts.yml` et relier les fixtures `subjects` / `respondents` existantes à leur contact. Vérification : `bin/rails test` passe sans changement de comportement.

## 2. Répercussion sur les brouillons

- [x] 2.1 Implémenter dans `Contact` les callbacks de D3 : mise à jour du nom et de l'e-mail des copies en brouillon, retrait des copies en brouillon quand un rôle est retiré ou le contact détruit, campagnes lancées et clôturées inchangées. Vérification : tests de modèle couvrant les quatre scénarios de « Répercussion sur les campagnes brouillon », dont la conservation des réponses et du jeton d'une campagne en cours.

## 3. Écran de l'annuaire

- [x] 3.1 Ajouter `Manager accepts_nested_attributes_for :contacts` (lignes vides rejetées, suppression autorisée) et la validation des doublons d'e-mail au sein d'un même envoi. Vérification : test de modèle où deux lignes de même e-mail sont refusées avec l'erreur sur la seconde.
- [x] 3.2 Créer la route `resource :team, only: %i[show update]`, `TeamsController` (authentification requise, `current_manager` uniquement, identifiants de contacts étrangers ignorés) et la vue (tableau nom, e-mail, cases managé / sondable, « Supprimer », `<template>` et bouton « Ajouter un contact » via `nested-form`, une ligne vide initiale, contacts triés par nom). Vérification : tests d'intégration `test/integration/team_test.rb` sur l'affichage, l'ajout, la modification, la suppression, la ligne vide ignorée, le réaffichage après erreur, la redirection sans connexion et l'isolation.
- [x] 3.3 Créer le contrôleur Stimulus du filtre Tous / Managés / Sondables, qui masque les lignes sans les retirer du formulaire. Vérification : test système où le filtre « Managés » masque un contact uniquement sondable, puis l'enregistrement conserve ce contact.
- [x] 3.4 Ajouter le lien « Mon équipe » dans la navigation de `layouts/application.html.erb` et styliser l'écran dans `application.css`, dans la direction visuelle colorée existante et lisible sur mobile. Vérification : test d'intégration sur la présence du lien pour un manager connecté, et contrôle visuel de l'écran en largeur mobile et en largeur bureau.

## 4. Sélection dans le formulaire de campagne

- [x] 4.1 Ajouter à `Campaign` les attributs virtuels `subject_contact_ids`, `respondent_contact_ids`, `new_subject_contacts` et `new_respondent_contacts`, ainsi que `assign_contacts` (D5) : réutilisation d'un contact existant par e-mail avec ajout du rôle, création des nouveaux contacts, filtrage par manager et par rôle, construction et suppression des copies, erreurs des nouveaux contacts remontées sur la campagne, le tout dans une seule transaction. Vérification : tests de modèle sur la sélection, la désélection, le nouveau contact, l'e-mail existant réutilisé, le contact invalide sans rien enregistrer et l'identifiant d'un autre manager ignoré.
- [x] 4.2 Mettre à jour `campaign_params` et `CampaignsController` (`subjects_attributes` / `respondents_attributes` retirés, `build_blank_rows` supprimé) et réécrire les sections Managés / Sondés de `_form.html.erb` (D6) : cases décochées à la création, cochées selon la campagne à la modification, état soumis reconstruit après une erreur, champ caché vide, message et lien quand l'annuaire est vide. Vérification : tests d'intégration de `test/integration/campaigns_test.rb` réécrits pour les scénarios « Lignes initiales » et « Édition dynamique » modifiés.
- [x] 4.3 Ajouter le bouton « Tout cocher » par section, avec son contrôleur Stimulus. Vérification : test système où « Tout cocher » sur les sondés puis l'enregistrement donnent tous les contacts sondables comme sondés.
- [x] 4.4 Mettre à jour `test/system/feedback_journey_test.rb` pour créer la campagne en cochant des contacts et en ajoutant un nouveau contact. Vérification : `bin/rails test:system` passe.

## 5. Reprise des données existantes

- [x] 5.1 Écrire la migration de données de D7 (modèles locaux à la migration : un contact par e-mail normalisé et par manager, nom le plus récent, rôles déduits, `contact_id` renseigné partout). Vérification : test qui charge un jeu de campagnes avec doublons d'e-mail en casses différentes, exécute la migration et vérifie les contacts créés et les liens posés ; relancer la migration ne crée aucun doublon.

## 6. Intégration

- [x] 6.1 Lancer la suite complète et `bin/rubocop`. Vérification : `bin/rails test`, `bin/rails test:system` et `bin/rubocop` sans échec.
