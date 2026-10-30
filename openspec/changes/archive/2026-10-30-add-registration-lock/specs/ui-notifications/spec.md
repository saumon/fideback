# Spec Delta

## ADDED Requirements

### Requirement: Toast d'avertissement
Le système SHALL proposer un toast d'avertissement, distinct de la notice et de l'alerte par sa couleur safran. Il SHALL disparaître de lui-même après un délai plus long que celui d'une notice de même texte, avec le même indicateur de temps restant, et SHALL se comporter comme une notice pour la suspension du minuteur, la fermeture, l'empilement et l'annonce aux lecteurs d'écran, qui est polie.

#### Scenario: Avertissement affiché
- **WHEN** un visiteur est ramené à l'accueil avec l'avertissement « Les inscriptions sont fermées pour le moment. »
- **THEN** un toast safran s'affiche par-dessus la page, avec un indicateur de temps restant

#### Scenario: Disparition plus tardive
- **WHEN** un avertissement et une notice de même texte s'affichent sans interaction
- **THEN** l'avertissement reste affiché plus longtemps que la notice avant de disparaître

#### Scenario: Fermeture et suspension
- **WHEN** l'utilisateur survole un avertissement ou le ferme avec son bouton
- **THEN** le décompte est suspendu pendant le survol, et le toast disparaît à la fermeture

#### Scenario: Avertissement annoncé
- **WHEN** une page s'affiche avec un avertissement
- **THEN** un lecteur d'écran annonce le message sans interrompre la lecture en cours

#### Scenario: Pile pleine
- **WHEN** le nombre de toasts dépasse la limite et que la pile contient un avertissement ancien
- **THEN** l'avertissement le plus ancien peut être retiré avant toute alerte, qui reste affichée
