# Design

## Context

- `CampaignsController#destroy` fait `@campaign.destroy` sans regarder l'état, puis redirige vers la liste avec « Campagne supprimée. ». `set_campaign` restreint déjà l'accès aux campagnes du manager connecté (`current_manager.campaigns.find`), donc la campagne d'un autre manager est introuvable, et `ApplicationController` renvoie un visiteur non connecté vers la connexion.
- La page `campaigns/show` n'affiche le bouton « Supprimer » que dans le bloc d'actions du brouillon. Une campagne en cours n'a que « Clôturer la campagne » ; une campagne clôturée n'a aucun bloc d'actions.
- `Campaign` détruit en cascade ses managés, ses sondés (et leurs réponses) et ses questions ; les contacts de l'annuaire sont référencés par une clé étrangère sans suppression (`dependent: nil`) : les copies de campagne disparaissent, l'annuaire reste. `Manager` détruit ses campagnes avec son compte.
- La boîte de confirmation prend son titre dans `data-turbo-confirm` et son détail, son ton et son icône dans `data-turbo-confirm-detail`, `-tone` et `-icon`. Le texte actuel du brouillon : « Supprimer cette campagne ? » / « Les réponses des sondés et la synthèse seront perdues. Cette action est définitive. ».
- `show` calcule déjà `@respondents` (avec leurs réponses) : le nombre de sondés et de sondés ayant soumis sont disponibles sans requête de plus.
- Aucun test n'appelle `destroy`.

## Goals / Non-Goals

**Goals:**
- Une règle d'état unique, appliquée par le serveur, que l'interface reflète.
- Réutiliser le bouton, la boîte et le message existants.

**Non-Goals:**
- Pas de nouvelle confirmation (nom à retaper, délai) : la boîte rouge actuelle suffit, avec un détail chiffré.
- Pas de suppression logique, de corbeille ni d'annulation.
- Pas de suppression depuis la liste des campagnes.

## Decisions

### 1. Le garde est dans le contrôleur, pas dans un callback du modèle

`Campaign#deletable?` vaut `!running?`. `destroy` refuse (redirection 303 vers la campagne, alerte « Cette campagne est en cours : clôturez-la avant de la supprimer. ») quand elle est fausse, et supprime sinon.

*Écarté :* un `before_destroy` qui lèverait ou renverrait faux pour une campagne en cours. `Manager has_many :campaigns, dependent: :destroy` passerait par ce callback : un manager ayant une campagne en cours ne pourrait plus supprimer son compte. La règle « pas de suppression d'une campagne en cours » est une règle d'action du manager sur une campagne, pas une règle d'intégrité des données.

### 2. Un seul bouton, deux emplacements

Le bouton « Supprimer » (danger, `turbo_confirm`, ton `danger`, icône `trash`) devient un partiel `campaigns/_delete_button.html.erb` utilisé dans le bloc d'actions du brouillon et dans un nouveau bloc d'actions de la campagne clôturée. Une campagne en cours n'en affiche pas. Le titre de la boîte reste « Supprimer cette campagne ? ».

### 3. Le détail de la boîte est calculé par un assistant

`CampaignsHelper#delete_campaign_detail(campaign, submitted, total)` rend :
- brouillon : le texte actuel, inchangé ;
- clôturée avec au moins une réponse : « Les réponses de N sondés sur M et la synthèse seront perdues. Cette action est définitive. » (« La réponse de 1 sondé sur M… » au singulier) ;
- clôturée sans réponse : « Aucun sondé n'a répondu. Cette action est définitive. ».

Les nombres viennent de `@respondents` (sondés ayant soumis, total de sondés), déjà chargé par `show`.

### 4. Aucune migration et aucun changement de modèle de données

La suppression en cascade existe déjà ; elle est maintenant testée (campagne, managés, sondés, réponses, questions supprimés, annuaire intact).

## Risks / Trade-offs

- [Une perte de données définitive sur une campagne qui contient toutes les réponses] → Boîte rouge, focus initial sur « Non, revenir », détail chiffré qui annonce ce qui disparaît. Un export avant suppression est écarté ici et reste une évolution possible.
- [Un manager qui supprimait une campagne en cours par une requête directe est désormais refusé] → C'est le but : l'interface ne l'a jamais proposé, et la règle protège les sondés qui répondent.
- [Supprimer une campagne juste après sa clôture automatique : l'e-mail au manager, déjà en file, ne retrouve plus la campagne] → La tâche échoue sans effet (campagne introuvable) ; le cas exige une suppression dans les secondes qui suivent la clôture et ne perd aucune donnée.
- [Le texte du détail se désynchronise du comportement réel] → Les tests d'intégration vérifient le texte exact pour les trois cas.

## Migration Plan

Aucune donnée ni migration. Déploiement ordinaire ; retour arrière par `git revert`.
