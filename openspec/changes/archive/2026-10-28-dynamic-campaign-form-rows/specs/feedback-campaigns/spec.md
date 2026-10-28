## ADDED Requirements

### Requirement: Édition dynamique des listes du formulaire de campagne
Le système SHALL permettre au manager d'ajouter et de supprimer des questions, des managés et des sondés directement depuis le formulaire de création ou de modification d'une campagne brouillon, sans recharger la page.

#### Scenario: Ajout d'une question
- **WHEN** un manager clique sur « Ajouter » dans la liste des questions puis enregistre la campagne avec un énoncé renseigné
- **THEN** la nouvelle question est enregistrée à la suite des existantes

#### Scenario: Ajout d'un managé ou d'un sondé
- **WHEN** un manager clique sur « Ajouter » dans la liste des managés ou des sondés, renseigne un nom et un e-mail, puis enregistre
- **THEN** le contact est enregistré dans la liste correspondante

#### Scenario: Suppression d'une ligne non enregistrée
- **WHEN** un manager supprime une ligne qu'il vient d'ajouter, ou une question par défaut du formulaire de création
- **THEN** la ligne disparaît du formulaire et n'est pas enregistrée

#### Scenario: Suppression d'une ligne enregistrée
- **WHEN** un manager supprime une question, un managé ou un sondé déjà enregistré puis enregistre la campagne
- **THEN** l'élément est supprimé de la campagne

#### Scenario: Conservation après erreur de validation
- **WHEN** l'enregistrement est refusé alors que le manager a ajouté ou supprimé des lignes
- **THEN** le formulaire est réaffiché avec les lignes ajoutées et sans celles supprimées

### Requirement: Ordre des questions
Le système SHALL conserver les questions d'une campagne dans l'ordre où elles apparaissent dans le formulaire à l'enregistrement.

#### Scenario: Question insérée parmi d'autres
- **WHEN** un manager ajoute une question puis enregistre la campagne
- **THEN** les questions sont ordonnées comme dans le formulaire, sans doublon de position

### Requirement: Lignes initiales du formulaire de campagne
Le système SHALL présenter à la création une ligne vide de managé et une ligne vide de sondé, avec les questions par défaut ; à la modification, il SHALL présenter les éléments existants et une ligne vide de managé et de sondé.

#### Scenario: Nouveau formulaire
- **WHEN** un manager ouvre le formulaire de création
- **THEN** il voit une ligne de managé vide, une ligne de sondé vide et les questions par défaut

#### Scenario: Ligne vide ignorée
- **WHEN** un manager enregistre la campagne en laissant une ligne vide
- **THEN** cette ligne est ignorée sans erreur
