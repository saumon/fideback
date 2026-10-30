# Spec Delta

## MODIFIED Requirements

### Requirement: Gestion des managés et des sondés
Le système SHALL constituer les managés et les sondés d'une campagne à partir des contacts de l'annuaire du manager ayant respectivement le rôle managé et le rôle sondable, chaque contact figurant au plus une fois par liste. La campagne conserve sa propre copie du nom et de l'e-mail, qui suit l'annuaire tant qu'elle est brouillon et est figée à son lancement.

#### Scenario: Doublon d'e-mail
- **WHEN** un manager ajoute depuis la campagne un nouveau contact dont l'e-mail existe déjà dans son annuaire
- **THEN** aucun doublon n'est créé : le contact existant est sélectionné et reçoit le rôle de la section s'il ne l'avait pas

#### Scenario: Sondé également managé
- **WHEN** une même personne figure à la fois parmi les sondés et les managés
- **THEN** elle est autorisée mais ne se voit pas proposer de répondre à propos d'elle-même

#### Scenario: Copie figée au lancement
- **WHEN** un manager lance une campagne puis modifie dans l'annuaire le nom ou l'e-mail d'un de ses managés ou sondés
- **THEN** la campagne lancée conserve le nom et l'e-mail qu'ils avaient au lancement

### Requirement: Édition dynamique des listes du formulaire de campagne
Le système SHALL permettre au manager, dans le formulaire de création ou de modification d'une campagne brouillon, d'ajouter et de supprimer des questions, de cocher et de décocher des contacts de l'annuaire comme managés ou sondés, et d'ajouter de nouveaux contacts, sans recharger la page.

#### Scenario: Ajout d'une question
- **WHEN** un manager clique sur « Ajouter » dans la liste des questions puis enregistre la campagne avec un énoncé renseigné
- **THEN** la nouvelle question est enregistrée à la suite des existantes

#### Scenario: Ajout d'un managé ou d'un sondé
- **WHEN** un manager coche un contact dans la liste des managés ou des sondés puis enregistre
- **THEN** le contact figure dans la liste correspondante de la campagne

#### Scenario: Nouveau contact depuis la campagne
- **WHEN** un manager clique sur « Nouveau contact » dans la liste des managés ou des sondés, renseigne un nom et un e-mail, puis enregistre
- **THEN** le contact est ajouté à l'annuaire avec le rôle de la section et figure dans la liste correspondante de la campagne

#### Scenario: Nouveau contact invalide
- **WHEN** l'enregistrement d'une campagne est refusé parce qu'un nouveau contact a un nom manquant ou un e-mail mal formé
- **THEN** ni la campagne ni l'annuaire ne sont modifiés et l'erreur est indiquée

#### Scenario: Suppression d'une ligne non enregistrée
- **WHEN** un manager supprime une ligne de nouveau contact qu'il vient d'ajouter, ou une question par défaut du formulaire de création
- **THEN** la ligne disparaît du formulaire et n'est pas enregistrée

#### Scenario: Suppression d'une ligne enregistrée
- **WHEN** un manager supprime une question déjà enregistrée, ou décoche un managé ou un sondé déjà enregistré, puis enregistre la campagne
- **THEN** l'élément est retiré de la campagne ; un contact décoché reste dans l'annuaire

#### Scenario: Conservation après erreur de validation
- **WHEN** l'enregistrement est refusé alors que le manager a coché, décoché ou ajouté des éléments
- **THEN** le formulaire est réaffiché avec les mêmes cases cochées, les lignes ajoutées et sans celles supprimées

### Requirement: Lignes initiales du formulaire de campagne
Le système SHALL présenter à la création, pour les managés comme pour les sondés, tous les contacts de l'annuaire ayant le rôle correspondant, décochés, avec les questions par défaut ; à la modification, il SHALL présenter les questions existantes et les mêmes listes de contacts, cochés pour ceux qui figurent dans la campagne.

#### Scenario: Nouveau formulaire
- **WHEN** un manager ouvre le formulaire de création
- **THEN** il voit ses contacts managés et ses contacts sondables, tous décochés, et les questions par défaut

#### Scenario: Formulaire de modification
- **WHEN** un manager ouvre le formulaire de modification d'une campagne brouillon
- **THEN** les contacts qui figurent dans la campagne sont cochés et les autres contacts du rôle sont décochés

#### Scenario: Annuaire vide
- **WHEN** un manager sans contact pour un rôle ouvre le formulaire de campagne
- **THEN** la section correspondante l'indique, propose « Nouveau contact » et un lien vers l'annuaire

#### Scenario: Ligne vide ignorée
- **WHEN** un manager enregistre la campagne en laissant une ligne de nouveau contact vide
- **THEN** cette ligne est ignorée sans erreur

## ADDED Requirements

### Requirement: Tout cocher
Le système SHALL proposer, dans les sections Managés et Sondés du formulaire de campagne, un bouton qui coche d'un coup tous les contacts de la section.

#### Scenario: Tout cocher les sondés
- **WHEN** un manager clique sur « Tout cocher » dans la section Sondés puis enregistre
- **THEN** tous ses contacts sondables figurent parmi les sondés de la campagne
