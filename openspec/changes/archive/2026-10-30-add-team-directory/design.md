# Design

## Context

Voir proposal.md (Why). Aujourd'hui, `Subject` et `Respondent` appartiennent chacun à une campagne et portent `name` et `email`, uniques par campagne. Ils sont saisis comme attributs imbriqués de `Campaign`, via `_contact_fields.html.erb` et `nested_form_controller.js`. `Respondent` porte en plus des données propres à la campagne (`token`, `submitted_at`, `last_invited_at`), et les `answers` référencent `subject_id` et `respondent_id`. `Campaign#content_frozen_once_launched` interdit déjà de toucher aux managés et sondés après le lancement.

## Goals / Non-Goals

**Goals:**
- Un modèle `Contact` par manager, source unique de saisie des managés et sondés.
- Garder `Subject` et `Respondent` comme copies : réponses, jetons et synthèses ne dépendent jamais de l'état courant de l'annuaire.
- Réutiliser les mécanismes existants (attributs imbriqués, `nested_form_controller.js`).

**Non-Goals:**
- Import en masse.
- Partage d'un annuaire entre managers.
- Historique des modifications d'un contact.

## Decisions

### D1. Table `contacts` avec deux booléens de rôle
`contacts(manager_id, name, email, managed:boolean, surveyable:boolean)`, avec un index unique sur `(manager_id, email)`. L'e-mail est normalisé comme dans `Subject` (`strip.downcase`). Une validation impose au moins un rôle.
*Alternative écartée* : deux tables, ou une table de rôles. Elles obligeraient à tenir deux fiches pour une personne à la fois managée et sondée, ce qui va contre le choix fait lors de l'exploration.

### D2. Copies reliées par un `contact_id` facultatif
On ajoute `contact_id` (nullable, `foreign_key on_delete: :nullify`) sur `subjects` et `respondents`, avec un index unique sur `(campaign_id, contact_id)`. La campagne garde ses propres `name` et `email`, et les validations existantes restent.
*Alternative écartée* : faire de `Subject` et `Respondent` de simples références vers `Contact`. Un renommage ou une suppression réécrirait des campagnes clôturées, ainsi que leurs synthèses et leurs e-mails déjà envoyés.

### D3. Répercussion vers les brouillons par callbacks de `Contact`
- `after_update` : si `name` ou `email` change, on met à jour les `subjects` et `respondents` liés dont la campagne est `draft`. Si `managed` passe à faux, on détruit les `subjects` liés en brouillon, et de même pour `surveyable` avec les `respondents`.
- `before_destroy` : on détruit les `subjects` et `respondents` liés en brouillon. La FK `nullify` détache ensuite ceux des campagnes lancées.

Ces callbacks passent par des requêtes directes, en jointure sur `campaigns.status = draft`. On n'enregistre donc pas la campagne, ce qui évite de déclencher `content_frozen_once_launched`. Un brouillon n'a ni réponses ni invitations, donc la destruction ne perd rien.
*Alternative écartée* : rafraîchir les copies à chaque enregistrement du brouillon. La page d'une campagne brouillon afficherait alors des noms périmés jusqu'à la prochaine sauvegarde.

### D4. Écran d'annuaire : formulaire unique sur `Manager`
On ajoute la route `resource :team, only: %i[show update]` (`/team`), servie par un `TeamsController`. On y édite `current_manager` avec `accepts_nested_attributes_for :contacts, allow_destroy: true, reject_if: :all_blank` sur nom et e-mail. Le partial de ligne et le `<template>` suivent le schéma de `_nested_rows.html.erb`, avec en plus deux cases à cocher de rôle.

La validation d'unicité d'Active Record ne voit pas les doublons entre lignes d'un même envoi. `Manager` ajoute donc une validation qui compare les e-mails normalisés des contacts non marqués pour suppression et pose l'erreur sur la ligne en double. L'index unique reste le dernier filet de sécurité. Le tout s'enregistre dans une seule transaction, via `update` du manager.

Le filtre Tous / Managés / Sondables est fait côté client : un contrôleur Stimulus `role-filter` masque les lignes selon leurs cases de rôle. Les lignes masquées restent dans le formulaire et sont soumises telles quelles.

Le lien « Mon équipe » se place dans la navigation, après « Mes campagnes ».

### D5. Sélection dans le formulaire de campagne : objet de formulaire léger dans `Campaign`
`Campaign` reçoit deux attributs virtuels de sélection, `subject_contact_ids` et `respondent_contact_ids`, et deux listes de nouveaux contacts, `new_subject_contacts` et `new_respondent_contacts` (tableaux de `{name, email}`). Une méthode `assign_contacts` les applique avant validation, uniquement en brouillon :
1. Pour chaque nouveau contact non vide, elle cherche un contact du manager par e-mail normalisé. S'il existe, elle lui ajoute le rôle. Sinon, elle construit un `Contact` avec le rôle. L'identifiant obtenu rejoint la sélection.
2. Elle restreint les identifiants à `manager.contacts` ayant le rôle (isolation, cf. spec).
3. Elle compare la sélection aux `subjects` et `respondents` existants : elle construit ceux qui manquent, en copiant nom et e-mail depuis le contact, et marque pour suppression ceux qui ne sont plus cochés.

Les nouveaux contacts sont enregistrés dans la même transaction que la campagne. Un contact invalide (nom manquant, e-mail mal formé) fait échouer la sauvegarde de la campagne, l'erreur étant remontée dans `errors` avec le nom de la ligne. Rien n'est écrit.

Les paramètres `subjects_attributes` et `respondents_attributes` disparaissent de `campaign_params`. Les cases à cocher sont précédées d'un champ caché vide, pour qu'une liste entièrement décochée soit bien soumise.

Pour réafficher le formulaire après une erreur, la vue reconstruit l'état coché à partir des identifiants soumis, et non de la base. Les lignes de nouveau contact sont rendues depuis les tableaux soumis.
*Alternative écartée* : un objet de formulaire séparé (`CampaignForm`). Le projet n'en a aucun, et l'enjeu reste contenu dans `Campaign`.

### D6. Composants de vue du formulaire de campagne
Chaque section Managés / Sondés comprend :
- une liste de cases `name="campaign[subject_contact_ids][]"` (nom et e-mail visibles) ;
- un bouton « Tout cocher », géré par le même contrôleur Stimulus `role-filter` ou un petit `check-all` ;
- un bloc `nested-form` pour les lignes « Nouveau contact » (nom, e-mail, « Supprimer »), sans ligne initiale ;
- un message et un lien vers l'annuaire quand aucun contact n'a le rôle.

`nested_form_controller.js` est réutilisé tel quel : les nouvelles lignes sont toujours `data-new-record=true`. Le style suit la direction visuelle colorée déjà en place.

### D7. Reprise des données existantes
Une migration de données, réversible par suppression de la table, parcourt les managers. Pour chaque e-mail normalisé présent dans les `subjects` ou `respondents` de ses campagnes, elle crée un contact :
- nom : celui de la ligne la plus récente ;
- `managed` : vrai si l'e-mail apparaît comme subject ;
- `surveyable` : vrai si l'e-mail apparaît comme respondent.

Elle renseigne ensuite `contact_id` sur toutes ces lignes, quel que soit l'état de la campagne. La migration écrit en SQL ou avec des modèles locaux à la migration, pour ne pas dépendre des callbacks de l'application.

## Risks / Trade-offs

- [Renommer un contact réécrit les brouillons sans prévenir] → C'est le comportement voulu par la spec. L'écran d'annuaire peut le signaler par une phrase d'aide.
- [Changer l'e-mail d'un contact présent dans un brouillon peut entrer en collision avec un autre `subject` du même brouillon sans `contact_id`] → Après la reprise, tout subject ou respondent a un `contact_id`, et les e-mails de contacts sont uniques par manager : la collision est impossible. Un test le couvre.
- [Le formulaire d'annuaire s'alourdit avec beaucoup de contacts] → Acceptable à l'échelle d'une équipe (quelques dizaines). La pagination est hors périmètre.
- [Le formulaire de campagne mêle deux sources, cases et nouveaux contacts] → On réaffiche à l'identique après une erreur (D5), et on teste les cas mixtes en intégration.
- [Les tests et fixtures existants reposent sur `subjects_attributes`] → On les réécrit dans le même groupe de tâches que le changement de formulaire.

## Migration Plan

1. Migration de schéma : `contacts` et `contact_id` sur `subjects` et `respondents`.
2. Migration de données (D7), dans un fichier distinct pour pouvoir la relancer.
3. Déploiement du code : annuaire, puis nouveau formulaire de campagne.

Retour arrière : on annule les migrations (suppression de `contact_id` puis de `contacts`). Les campagnes gardent leurs copies `name` et `email`, donc aucune donnée de campagne n'est perdue.
