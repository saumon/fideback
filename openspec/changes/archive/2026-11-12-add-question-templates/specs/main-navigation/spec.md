# Spec Delta

## ADDED Requirements

### Requirement: Entrée des modèles de questions
Le système SHALL proposer aux managers connectés une entrée « Mes modèles » dans la navigation principale, signalée comme page courante sur tous les écrans de gestion des modèles de questions (liste, création, détail, modification).

#### Scenario: Liste des modèles
- **WHEN** un manager connecté ouvre la liste de ses modèles
- **THEN** l'entrée « Mes modèles » est signalée comme page courante et aucune autre entrée ne l'est

#### Scenario: Création ou modification d'un modèle
- **WHEN** un manager connecté ouvre la création ou la modification d'un modèle, y compris après un enregistrement refusé
- **THEN** l'entrée « Mes modèles » est signalée comme page courante

#### Scenario: Visiteur non connecté
- **WHEN** un visiteur non connecté consulte la navigation
- **THEN** l'entrée « Mes modèles » ne lui est pas proposée
