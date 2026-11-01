# Spec Delta

## ADDED Requirements

### Requirement: Confirmation au sondé dont la soumission clôt la campagne
Le système SHALL montrer au sondé dont la soumission clôture la campagne la même confirmation qu'à tout autre sondé qui soumet, et MUST NOT lui indiquer que la campagne est terminée comme s'il arrivait trop tard.

#### Scenario: Dernier sondé
- **WHEN** le dernier sondé soumet et que la campagne se clôture
- **THEN** il voit « Merci ! Vos réponses ont été soumises » et le message « Vous avez soumis vos réponses », sans le message de campagne terminée

#### Scenario: Retour sur son lien
- **WHEN** ce sondé rouvre son lien après la clôture
- **THEN** il voit toujours qu'il a soumis ses réponses, en lecture seule
