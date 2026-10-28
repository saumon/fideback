# feedback-campaigns Specification

## Purpose

Permettre à un manager de définir et piloter une campagne de feedback visant une liste finie de managés et une liste finie de sondés, de sa préparation à sa clôture.

## Requirements

### Requirement: Création d'une campagne
Le système SHALL permettre à un manager de créer une campagne avec un nom, une date limite de réponse, au moins un managé et au moins un sondé.

#### Scenario: Création valide
- **WHEN** un manager soumet un nom, une date limite future, un managé et un sondé valides
- **THEN** la campagne est créée à l'état brouillon et affichée dans sa liste

#### Scenario: Campagne sans sondé
- **WHEN** un manager tente de lancer une campagne sans sondé ou sans managé
- **THEN** le lancement est refusé et l'erreur est indiquée

### Requirement: Gestion des managés et des sondés
Le système SHALL gérer les managés et les sondés d'une campagne comme des contacts identifiés par un nom et une adresse e-mail unique au sein de leur liste.

#### Scenario: Doublon d'e-mail
- **WHEN** un manager ajoute deux sondés avec le même e-mail dans une même campagne
- **THEN** le second ajout est refusé

#### Scenario: Sondé également managé
- **WHEN** une même personne figure à la fois parmi les sondés et les managés
- **THEN** elle est autorisée mais ne se voit pas proposer de répondre à propos d'elle-même

### Requirement: Questionnaire de campagne
Le système SHALL associer à chaque campagne une liste ordonnée de questions, chacune comportant un commentaire texte libre et/ou une note de 1 à 5 (au moins l'un des deux), avec un jeu de questions par défaut à la création.

#### Scenario: Questions par défaut
- **WHEN** un manager commence une nouvelle campagne
- **THEN** le formulaire est pré-rempli avec le jeu de questions par défaut, modifiable avant le lancement

#### Scenario: Modification après lancement
- **WHEN** un manager tente de modifier les questions, les managés ou les sondés d'une campagne lancée
- **THEN** la modification est refusée

#### Scenario: Question sans type de réponse
- **WHEN** un manager enregistre une question sans note ni commentaire
- **THEN** l'enregistrement est refusé

### Requirement: Cycle de vie de la campagne
Le système SHALL faire passer une campagne par les états brouillon, en cours puis clôturée, de façon irréversible vers l'avant.

#### Scenario: Lancement
- **WHEN** un manager lance une campagne brouillon valide
- **THEN** elle passe à l'état en cours, les invitations sont envoyées aux sondés et leur date d'invitation est enregistrée

#### Scenario: Clôture manuelle
- **WHEN** un manager clôture une campagne en cours
- **THEN** elle passe à l'état clôturée et les liens des sondés n'acceptent plus de réponse

#### Scenario: Date limite dépassée
- **WHEN** la date limite d'une campagne en cours est dépassée
- **THEN** les liens des sondés n'acceptent plus de nouvelle réponse

### Requirement: Suivi de l'avancement
Le système SHALL afficher au manager, pour chaque sondé d'une campagne en cours, s'il a répondu, partiellement répondu ou pas encore répondu, ainsi que la date de sa dernière invitation.

#### Scenario: Consultation du suivi
- **WHEN** un manager ouvre sa campagne en cours
- **THEN** il voit le statut de chaque sondé, la date de dernière invitation et le taux de réponse global

#### Scenario: Invitation datée après renvoi
- **WHEN** un manager renvoie l'invitation à un sondé
- **THEN** la date de dernière invitation affichée pour ce sondé est celle du renvoi

### Requirement: Renvoi d'une invitation
Le système SHALL permettre à un manager de renvoyer l'email d'invitation, avec le même lien personnel, à un sondé qui n'a pas encore soumis ses réponses, tant que la campagne est en cours et accepte des réponses.

#### Scenario: Renvoi nominal
- **WHEN** un manager renvoie l'invitation à un sondé n'ayant pas soumis, dans une campagne en cours dont la date limite n'est pas dépassée
- **THEN** l'email d'invitation est envoyé à ce sondé avec le même lien qu'à l'origine et la date de dernière invitation est mise à jour

#### Scenario: Sondé ayant déjà soumis
- **WHEN** un manager tente de renvoyer l'invitation à un sondé ayant soumis ses réponses
- **THEN** aucun email n'est envoyé, le renvoi est refusé et le bouton n'est pas proposé

#### Scenario: Campagne qui n'accepte plus de réponses
- **WHEN** un manager tente de renvoyer une invitation d'une campagne brouillon, clôturée ou dont la date limite est dépassée
- **THEN** aucun email n'est envoyé, le renvoi est refusé et le bouton n'est pas proposé

#### Scenario: Campagne d'un autre manager
- **WHEN** un manager tente de renvoyer une invitation pour un sondé d'une campagne appartenant à un autre manager
- **THEN** le système répond comme si le sondé n'existait pas

### Requirement: Isolation entre managers
Le système SHALL réserver l'accès à une campagne et à ses données à son manager propriétaire.

#### Scenario: Accès à la campagne d'un autre manager
- **WHEN** un manager demande l'URL d'une campagne appartenant à un autre manager
- **THEN** le système répond comme si la campagne n'existait pas

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
