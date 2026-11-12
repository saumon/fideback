# Spec Delta

## Purpose

Permettre aux managers de réutiliser des jeux de questions d'une campagne à l'autre, à partir d'un modèle par défaut fourni par le système et de leurs propres modèles.

## ADDED Requirements

### Requirement: Modèle par défaut du système
Le système SHALL fournir à tous les managers un modèle par défaut, composé de quatre questions : « Qualité du travail réalisé cette année » (note et commentaire), « Collaboration et esprit d'équipe » (note et commentaire), « Points forts à valoriser » (commentaire) et « Axes de progrès » (commentaire). Ce modèle SHALL être consultable mais ni modifiable ni supprimable par un manager.

#### Scenario: Modèle par défaut présent
- **WHEN** un manager ouvre la liste de ses modèles
- **THEN** le modèle par défaut y figure, identifié comme fourni par le système, avec ses quatre questions

#### Scenario: Modification ou suppression refusée
- **WHEN** un manager tente de modifier ou de supprimer le modèle par défaut
- **THEN** l'opération est refusée, le modèle reste inchangé, et aucun bouton de modification ou de suppression n'est proposé

### Requirement: Gestion des modèles d'un manager
Le système SHALL permettre à un manager de créer, modifier et supprimer ses propres modèles. Un modèle comporte un nom et une liste ordonnée de questions, chacune avec un énoncé et une note de 1 à 5 et/ou un commentaire.

#### Scenario: Création d'un modèle
- **WHEN** un manager enregistre un modèle avec un nom et au moins une question valide
- **THEN** le modèle est créé et figure dans sa liste

#### Scenario: Modèle sans nom ou sans question
- **WHEN** un manager enregistre un modèle sans nom, ou sans aucune question
- **THEN** l'enregistrement est refusé et l'erreur est indiquée

#### Scenario: Question sans type de réponse
- **WHEN** un manager enregistre un modèle dont une question n'a ni note ni commentaire
- **THEN** l'enregistrement est refusé

#### Scenario: Édition dynamique des questions
- **WHEN** un manager ajoute, supprime ou réordonne des questions dans le formulaire d'un modèle puis enregistre
- **THEN** le modèle conserve les questions dans l'ordre du formulaire

#### Scenario: Modification d'un modèle
- **WHEN** un manager modifie un de ses modèles
- **THEN** les campagnes déjà créées, même brouillons, gardent leurs questions inchangées

#### Scenario: Suppression d'un modèle
- **WHEN** un manager confirme la suppression d'un de ses modèles
- **THEN** le modèle disparaît de sa liste et les campagnes déjà créées avec ce modèle ne changent pas

### Requirement: Isolation des modèles entre managers
Le système SHALL réserver un modèle propre à son manager : un autre manager ne peut ni le voir, ni le choisir, ni le modifier, ni le supprimer.

#### Scenario: Modèle d'un autre manager
- **WHEN** un manager demande l'URL d'un modèle appartenant à un autre manager
- **THEN** le système répond comme si le modèle n'existait pas

#### Scenario: Liste des modèles
- **WHEN** un manager ouvre la liste de ses modèles
- **THEN** il y voit le modèle par défaut puis ses propres modèles, et aucun modèle d'un autre manager

### Requirement: Suppression du compte et modèles
Le système SHALL supprimer les modèles d'un manager avec son compte, sans toucher au modèle par défaut.

#### Scenario: Suppression d'un manager
- **WHEN** l'Admin supprime le compte d'un manager qui a des modèles
- **THEN** ses modèles sont supprimés et le modèle par défaut reste disponible pour les autres managers
