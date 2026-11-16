# Spec Delta

## ADDED Requirements

### Requirement: Motif visible sur la page de la campagne
Le système SHALL afficher au manager, sur la page de sa campagne, le motif « Pourquoi cette campagne ? » lorsqu'il est renseigné, sous l'en-tête et avant les boutons d'action, quel que soit l'état de la campagne.

#### Scenario: Page d'une campagne avec motif
- **WHEN** un manager ouvre une campagne dont le motif est renseigné, en brouillon, en cours ou clôturée
- **THEN** la page affiche ce motif sous le titre « Pourquoi cette campagne ? », sous l'en-tête et avant les boutons d'action

#### Scenario: Page d'une campagne sans motif
- **WHEN** un manager ouvre une campagne dont le motif est vide ou ne contient que des espaces
- **THEN** aucun bloc de motif n'apparaît, ni rappel ni invitation à le renseigner

#### Scenario: Texte saisi traité comme du texte
- **WHEN** le motif contient des balises HTML
- **THEN** elles sont affichées telles quelles et non interprétées, et les retours à la ligne sont conservés
