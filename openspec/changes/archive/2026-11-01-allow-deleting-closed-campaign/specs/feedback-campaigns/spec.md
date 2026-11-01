# Spec Delta

## ADDED Requirements

### Requirement: Suppression d'une campagne
Le système SHALL permettre au manager propriétaire de supprimer une campagne brouillon ou clôturée, et MUST refuser de supprimer une campagne en cours. La suppression MUST emporter la campagne, ses managés, ses sondés, leurs réponses et ses questions, et ne MUST PAS toucher à l'annuaire d'équipe du manager.

#### Scenario: Campagne clôturée
- **WHEN** un manager supprime une de ses campagnes clôturées
- **THEN** la campagne disparaît de sa liste, un message « Campagne supprimée. » s'affiche, et ses managés, sondés, réponses et questions sont supprimés

#### Scenario: Campagne brouillon
- **WHEN** un manager supprime une de ses campagnes brouillon
- **THEN** la campagne est supprimée comme une campagne clôturée

#### Scenario: Campagne en cours
- **WHEN** un manager demande la suppression d'une de ses campagnes en cours, même par une requête qui ne passe pas par l'interface
- **THEN** la campagne est conservée et un message l'invite à la clôturer avant de la supprimer

#### Scenario: Annuaire intact
- **WHEN** un manager supprime une campagne dont il avait choisi les managés et les sondés dans son annuaire
- **THEN** ces contacts restent dans son annuaire d'équipe

#### Scenario: Lien d'un sondé
- **WHEN** un sondé ouvre son lien personnel après la suppression de la campagne
- **THEN** le système répond comme si la page n'existait pas

#### Scenario: Campagne d'un autre manager
- **WHEN** un manager demande la suppression d'une campagne appartenant à un autre manager
- **THEN** le système répond comme si la campagne n'existait pas et la campagne est conservée

#### Scenario: Visiteur non connecté
- **WHEN** un visiteur non connecté demande la suppression d'une campagne
- **THEN** il est renvoyé vers la connexion et la campagne est conservée

#### Scenario: Suppression du compte
- **WHEN** un manager supprime son compte alors qu'il a une campagne en cours
- **THEN** ses campagnes sont supprimées avec le compte, quel que soit leur état

### Requirement: Confirmation chiffrée de la suppression d'une campagne clôturée
Le système SHALL, avant de supprimer une campagne clôturée, demander une confirmation qui annonce combien de sondés sur combien ont répondu et que la synthèse sera perdue, et MUST préciser que l'action est définitive. Le bouton de suppression n'apparaît que sur la page d'une campagne brouillon ou clôturée.

#### Scenario: Campagne avec des réponses
- **WHEN** un manager clique sur « Supprimer » sur la page d'une campagne clôturée dont 2 sondés sur 3 ont répondu
- **THEN** la boîte demande « Supprimer cette campagne ? » et précise que les réponses de 2 sondés sur 3 et la synthèse seront perdues, et que l'action est définitive

#### Scenario: Campagne sans réponse
- **WHEN** un manager clique sur « Supprimer » sur la page d'une campagne clôturée sans aucune réponse soumise
- **THEN** la boîte précise qu'aucun sondé n'a répondu et que l'action est définitive

#### Scenario: Retrait
- **WHEN** le manager ferme la boîte avec « Non, revenir »
- **THEN** la campagne est conservée

#### Scenario: Campagne en cours
- **WHEN** un manager ouvre la page d'une de ses campagnes en cours
- **THEN** aucun bouton de suppression n'est affiché
