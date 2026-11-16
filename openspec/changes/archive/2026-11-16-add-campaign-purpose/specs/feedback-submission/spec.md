# Spec Delta

## MODIFIED Requirements

### Requirement: Invitation par e-mail
Le système SHALL envoyer à chaque sondé, au lancement de la campagne, un e-mail contenant un lien personnel non devinable. L'e-mail SHALL NOT présenter la campagne comme une préparation d'entretiens individuels et SHALL reprendre le motif de la campagne lorsqu'il est renseigné.

#### Scenario: Envoi des invitations
- **WHEN** un manager lance une campagne
- **THEN** chaque sondé reçoit un e-mail avec son lien personnel, le nom du manager et la date limite

#### Scenario: Formulation neutre
- **WHEN** un sondé reçoit l'invitation
- **THEN** l'e-mail, en HTML comme en texte, invite à donner son feedback sans mentionner d'entretiens individuels

#### Scenario: Invitation avec motif
- **WHEN** la campagne a un motif
- **THEN** l'e-mail, en HTML comme en texte, affiche ce motif sous le titre « Pourquoi cette campagne ? »

#### Scenario: Invitation sans motif
- **WHEN** la campagne n'a pas de motif, ou seulement des espaces
- **THEN** l'e-mail ne contient ni ce titre ni bloc vide

## ADDED Requirements

### Requirement: Motif de la campagne affiché au sondé
Le système SHALL afficher le motif de la campagne en tête du formulaire de réponse, quel que soit l'état de la campagne, lorsqu'il est renseigné.

#### Scenario: Formulaire avec motif
- **WHEN** un sondé ouvre son lien et que la campagne a un motif
- **THEN** le formulaire affiche ce motif, sous le titre « Pourquoi cette campagne ? », avant les questions

#### Scenario: Formulaire sans motif
- **WHEN** un sondé ouvre son lien et que la campagne n'a pas de motif
- **THEN** aucun bloc de motif n'apparaît

#### Scenario: Texte saisi traité comme du texte
- **WHEN** le motif contient des balises HTML
- **THEN** elles sont affichées telles quelles et non interprétées, et les retours à la ligne sont conservés
