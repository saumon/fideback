# feedback-synthesis Specification

## Purpose

Fournir au manager une vue consolidée et nominative des feedbacks reçus sur chaque managé afin de préparer son entretien individuel.

## Requirements

### Requirement: Synthèse par managé
Le système SHALL afficher au manager, pour chaque managé, les réponses consolidées de toutes les soumissions finales de la campagne.

#### Scenario: Consultation de la synthèse
- **WHEN** un manager ouvre la synthèse d'un managé
- **THEN** il voit, pour chaque question à note, la moyenne et le nombre de réponses, et pour chaque question à commentaire, la liste des commentaires

### Requirement: Réponses nominatives
Le système SHALL identifier, dans la synthèse, le sondé auteur de chaque note et de chaque commentaire.

#### Scenario: Commentaire avec auteur
- **WHEN** la synthèse affiche un commentaire ou une note
- **THEN** le nom du sondé qui l'a donné est affiché à côté

### Requirement: Prise en compte des seules soumissions finales
Le système SHALL exclure de la synthèse les réponses partielles non soumises.

#### Scenario: Réponses en cours de saisie
- **WHEN** un sondé a enregistré des réponses sans les soumettre définitivement
- **THEN** ces réponses n'apparaissent pas dans la synthèse

### Requirement: Information des sondés
Le système SHALL informer le sondé, sur son formulaire de réponse, que ses réponses seront communiquées nominativement au manager.

#### Scenario: Mention sur le formulaire
- **WHEN** un sondé ouvre son lien personnel
- **THEN** un message indique que ses réponses seront visibles du manager avec son nom

### Requirement: Accès restreint à la synthèse
Le système SHALL réserver la synthèse au manager propriétaire de la campagne.

#### Scenario: Accès par un sondé ou un autre manager
- **WHEN** un sondé via son lien, ou un autre manager, demande l'URL d'une synthèse
- **THEN** le système répond comme si la page n'existait pas
