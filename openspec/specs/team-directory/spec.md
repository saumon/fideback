# team-directory Specification

## Purpose

Permettre à un manager de tenir une fois pour toutes la liste des personnes qu'il évalue et de celles qu'il peut interroger, afin de la réutiliser d'une campagne de feedback à l'autre.

## Requirements

### Requirement: Contacts de l'annuaire
Le système SHALL conserver pour chaque manager un annuaire de contacts, chacun identifié par un nom et une adresse e-mail unique dans cet annuaire, sans distinction de casse ni d'espaces en bordure.

#### Scenario: Ajout d'un contact
- **WHEN** un manager enregistre un contact avec un nom, un e-mail valide et au moins un rôle
- **THEN** le contact apparaît dans son annuaire et reste disponible pour toutes ses campagnes futures

#### Scenario: Doublon d'e-mail
- **WHEN** un manager enregistre un contact dont l'e-mail, à la casse près, est déjà celui d'un autre contact de son annuaire, ou deux contacts de même e-mail dans un même enregistrement
- **THEN** l'enregistrement est refusé et l'erreur est indiquée sur la ligne concernée

#### Scenario: E-mail invalide ou nom manquant
- **WHEN** un manager enregistre un contact sans nom ou avec un e-mail mal formé
- **THEN** l'enregistrement est refusé et l'erreur est indiquée

### Requirement: Rôles d'un contact
Le système SHALL attribuer à chaque contact un ou deux rôles parmi « managé » (personne sur laquelle porte le feedback) et « sondable » (personne pouvant être interrogée), et refuser un contact sans rôle.

#### Scenario: Contact managé et sondable
- **WHEN** un manager coche les deux rôles pour un contact
- **THEN** le contact est proposé à la fois parmi les managés et parmi les sondés des campagnes

#### Scenario: Contact sans rôle
- **WHEN** un manager enregistre un contact sans cocher aucun rôle
- **THEN** l'enregistrement est refusé et l'erreur est indiquée

### Requirement: Écran de l'annuaire
Le système SHALL offrir au manager connecté un écran dédié, accessible depuis la navigation principale, où il ajoute, modifie et supprime ses contacts et les enregistre en une fois, l'ajout et la suppression de lignes se faisant sans recharger la page.

#### Scenario: Accès depuis la navigation
- **WHEN** un manager connecté clique sur le lien de l'annuaire dans la navigation principale
- **THEN** il voit ses contacts triés par nom, avec leurs rôles, et une ligne vide pour en ajouter un

#### Scenario: Suppression d'un contact
- **WHEN** un manager supprime une ligne de contact enregistrée puis enregistre l'annuaire
- **THEN** le contact disparaît de l'annuaire

#### Scenario: Ligne vide ignorée
- **WHEN** un manager enregistre l'annuaire en laissant une ligne sans nom ni e-mail
- **THEN** cette ligne est ignorée sans erreur

#### Scenario: Conservation après erreur de validation
- **WHEN** l'enregistrement de l'annuaire est refusé alors que le manager a ajouté, modifié ou supprimé des lignes
- **THEN** l'écran est réaffiché avec ses saisies, sans les lignes supprimées, et rien n'est enregistré

#### Scenario: Accès sans être connecté
- **WHEN** un visiteur non connecté demande l'écran de l'annuaire
- **THEN** il est redirigé vers la page de connexion

### Requirement: Filtre par rôle
Le système SHALL permettre de restreindre l'affichage de l'annuaire aux contacts managés ou aux contacts sondables, sans recharger la page.

#### Scenario: Filtre « Managés »
- **WHEN** un manager choisit le filtre « Managés »
- **THEN** seuls les contacts ayant le rôle managé restent affichés, et les autres restent intacts à l'enregistrement

### Requirement: Isolation des annuaires
Le système SHALL réserver l'annuaire d'un manager et ses contacts à ce seul manager.

#### Scenario: Contact d'un autre manager
- **WHEN** un manager soumet, dans l'annuaire ou dans une campagne, l'identifiant d'un contact appartenant à un autre manager
- **THEN** cet identifiant est ignoré et le contact de l'autre manager n'est ni lu ni modifié

#### Scenario: Même e-mail chez deux managers
- **WHEN** deux managers enregistrent chacun un contact avec le même e-mail
- **THEN** les deux enregistrements sont acceptés

### Requirement: Répercussion sur les campagnes brouillon
Le système SHALL répercuter les changements de l'annuaire sur les managés et sondés des campagnes brouillon qui en sont issus, et SHALL laisser intacts ceux des campagnes en cours ou clôturées.

#### Scenario: Contact modifié
- **WHEN** un manager modifie le nom ou l'e-mail d'un contact sélectionné dans une campagne brouillon
- **THEN** le managé ou le sondé correspondant de cette campagne porte le nouveau nom et le nouvel e-mail

#### Scenario: Contact supprimé
- **WHEN** un manager supprime un contact sélectionné dans une campagne brouillon
- **THEN** ce contact est retiré des managés et des sondés de cette campagne

#### Scenario: Rôle retiré
- **WHEN** un manager retire le rôle managé (ou sondable) d'un contact sélectionné comme managé (ou sondé) dans une campagne brouillon
- **THEN** ce contact est retiré des managés (ou des sondés) de cette campagne

#### Scenario: Campagne lancée
- **WHEN** un manager modifie ou supprime un contact qui figure dans une campagne en cours ou clôturée
- **THEN** le managé ou le sondé de cette campagne, ses réponses, son lien personnel et la synthèse restent inchangés
