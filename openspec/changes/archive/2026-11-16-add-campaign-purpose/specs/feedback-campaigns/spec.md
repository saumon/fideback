# Spec Delta

## MODIFIED Requirements

### Requirement: Création d'une campagne
Le système SHALL permettre à un manager de créer une campagne avec un nom, une date limite de réponse, au moins un managé et au moins un sondé, et, facultativement, un motif intitulé « Pourquoi cette campagne ? » de 1000 caractères au plus.

#### Scenario: Création valide
- **WHEN** un manager soumet un nom, une date limite future, un managé et un sondé valides
- **THEN** la campagne est créée à l'état brouillon et affichée dans sa liste

#### Scenario: Campagne sans sondé
- **WHEN** un manager tente de lancer une campagne sans sondé ou sans managé
- **THEN** le lancement est refusé et l'erreur est indiquée

#### Scenario: Création avec motif
- **WHEN** un manager renseigne « Pourquoi cette campagne ? » avec un texte de 1000 caractères ou moins
- **THEN** la campagne est créée avec ce motif, qu'il retrouve en la modifiant tant qu'elle est en brouillon

#### Scenario: Création sans motif
- **WHEN** un manager laisse « Pourquoi cette campagne ? » vide
- **THEN** la campagne est créée normalement, sans motif

#### Scenario: Motif trop long
- **WHEN** un manager saisit un motif de plus de 1000 caractères
- **THEN** l'enregistrement est refusé et l'erreur est indiquée sur ce champ
