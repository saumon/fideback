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

### Requirement: Ordre des questions
Le système SHALL conserver les questions d'une campagne dans l'ordre où elles apparaissent dans le formulaire à l'enregistrement.

#### Scenario: Question insérée parmi d'autres
- **WHEN** un manager ajoute une question puis enregistre la campagne
- **THEN** les questions sont ordonnées comme dans le formulaire, sans doublon de position

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

### Requirement: Tout cocher
Le système SHALL proposer, dans les sections Managés et Sondés du formulaire de campagne, un bouton qui coche d'un coup tous les contacts de la section.

#### Scenario: Tout cocher les sondés
- **WHEN** un manager clique sur « Tout cocher » dans la section Sondés puis enregistre
- **THEN** tous ses contacts sondables figurent parmi les sondés de la campagne

### Requirement: Clôture automatique à la dernière soumission
Le système SHALL clôturer automatiquement une campagne en cours dès que tous ses sondés ont soumis définitivement leurs réponses. Cette règle MUST s'appliquer à toute campagne, sans réglage.

#### Scenario: Dernier sondé
- **WHEN** le dernier sondé d'une campagne en cours soumet ses réponses alors que tous les autres ont déjà soumis
- **THEN** la campagne passe à l'état clôturée et les liens des sondés n'acceptent plus de réponse

#### Scenario: Il reste des sondés
- **WHEN** un sondé soumet ses réponses alors qu'un autre sondé de la campagne n'a pas encore soumis
- **THEN** la campagne reste en cours

#### Scenario: Réponses non soumises
- **WHEN** un sondé a enregistré des réponses sans les soumettre définitivement et que tous les autres ont soumis
- **THEN** la campagne reste en cours

#### Scenario: Campagne à un seul sondé
- **WHEN** l'unique sondé d'une campagne en cours soumet ses réponses
- **THEN** la campagne passe à l'état clôturée

#### Scenario: Soumission après la date limite
- **WHEN** un sondé tente de soumettre ses réponses après la date limite de la campagne
- **THEN** la soumission est refusée et l'état de la campagne ne change pas

#### Scenario: Clôture simultanée
- **WHEN** les deux derniers sondés soumettent au même instant
- **THEN** la campagne est clôturée une seule fois

#### Scenario: Campagnes déjà en cours
- **WHEN** la règle est mise en service alors qu'une campagne en cours a déjà toutes ses soumissions
- **THEN** cette campagne n'est pas clôturée tant qu'aucune nouvelle soumission n'a lieu

### Requirement: E-mail au manager à la clôture automatique
Le système SHALL envoyer au manager, quand sa campagne est clôturée automatiquement, un e-mail qui annonce que tous ses sondés ont répondu, donne le nom de la campagne et le nombre de réponses, et mène à la campagne et à sa synthèse. Cet e-mail MUST partir une seule fois par campagne.

#### Scenario: Envoi à la clôture
- **WHEN** la soumission du dernier sondé clôture la campagne « Entretiens 2026 »
- **THEN** son manager reçoit un e-mail dont l'objet est « Tous vos sondés ont répondu : campagne clôturée », qui nomme la campagne, donne le nombre de réponses et propose un bouton vers la campagne

#### Scenario: Salutation et habillage
- **WHEN** le manager Alice Manager reçoit cet e-mail
- **THEN** il commence par « Bonjour Alice Manager, » dans ses versions HTML et texte, avec l'habillage commun des e-mails

#### Scenario: Aucun e-mail sans clôture automatique
- **WHEN** un manager clôture lui-même sa campagne, ou qu'un sondé soumet sans que tous aient répondu
- **THEN** aucun e-mail de clôture automatique n'est envoyé

#### Scenario: Envoi unique
- **WHEN** deux soumissions simultanées clôturent la même campagne
- **THEN** le manager ne reçoit qu'un seul e-mail

#### Scenario: Échec de l'envoi
- **WHEN** l'envoi de l'e-mail échoue
- **THEN** la campagne reste clôturée et les réponses des sondés restent soumises

### Requirement: Cause de la clôture affichée
Le système SHALL afficher, dans la page d'une campagne clôturée dont tous les sondés ont soumis leurs réponses, une ligne d'état « Clôturée : tous les sondés ont répondu ». Cette ligne MUST faire partie du contenu de la page et ne pas disparaître d'elle-même.

#### Scenario: Campagne terminée par les réponses
- **WHEN** un manager ouvre une campagne clôturée dont tous les sondés ont soumis
- **THEN** la ligne « Clôturée : tous les sondés ont répondu » est affichée dans la page

#### Scenario: Clôture avec des sondés manquants
- **WHEN** un manager ouvre une campagne qu'il a clôturée alors qu'un sondé n'avait pas soumis
- **THEN** la ligne n'est pas affichée

### Requirement: Suppression d'une campagne
Le système SHALL permettre au manager propriétaire de supprimer une campagne brouillon ou clôturée, et MUST refuser de supprimer une campagne en cours. La suppression MUST emporter la campagne, ses managés, ses sondés, leurs réponses et ses questions, et ne MUST PAS toucher à l'annuaire d'équipe du manager.

#### Scenario: Campagne clôturée
- **WHEN** un manager supprime une de ses campagnes clôturées
- **THEN** la campagne disparaît de sa liste, un message « Campagne supprimée. » s'affiche, et ses managés, sondés, réponses et questions sont supprimés

#### Scenario: Campagne brouillon
- **WHEN** un manager supprime une de ses campagnes brouillon
- **THEN** la campagne est supprimée comme une campagne clôturée

#### Scenario: Campagne en cours
- **WHEN** un manager demande la suppression d'une de ses campagnes en cours, même par une requête qui ne passe pas par l'interface
- **THEN** la campagne est conservée et un message l'invite à la clôturer avant de la supprimer

#### Scenario: Annuaire intact
- **WHEN** un manager supprime une campagne dont il avait choisi les managés et les sondés dans son annuaire
- **THEN** ces contacts restent dans son annuaire d'équipe

#### Scenario: Lien d'un sondé
- **WHEN** un sondé ouvre son lien personnel après la suppression de la campagne
- **THEN** le système répond comme si la page n'existait pas

#### Scenario: Campagne d'un autre manager
- **WHEN** un manager demande la suppression d'une campagne appartenant à un autre manager
- **THEN** le système répond comme si la campagne n'existait pas et la campagne est conservée

#### Scenario: Visiteur non connecté
- **WHEN** un visiteur non connecté demande la suppression d'une campagne
- **THEN** il est renvoyé vers la connexion et la campagne est conservée

#### Scenario: Suppression du compte
- **WHEN** un manager supprime son compte alors qu'il a une campagne en cours
- **THEN** ses campagnes sont supprimées avec le compte, quel que soit leur état

### Requirement: Confirmation chiffrée de la suppression d'une campagne clôturée
Le système SHALL, avant de supprimer une campagne clôturée, demander une confirmation qui annonce combien de sondés sur combien ont répondu et que la synthèse sera perdue, et MUST préciser que l'action est définitive. Le bouton de suppression n'apparaît que sur la page d'une campagne brouillon ou clôturée.

#### Scenario: Campagne avec des réponses
- **WHEN** un manager clique sur « Supprimer » sur la page d'une campagne clôturée dont 2 sondés sur 3 ont répondu
- **THEN** la boîte demande « Supprimer cette campagne ? » et précise que les réponses de 2 sondés sur 3 et la synthèse seront perdues, et que l'action est définitive

#### Scenario: Campagne sans réponse
- **WHEN** un manager clique sur « Supprimer » sur la page d'une campagne clôturée sans aucune réponse soumise
- **THEN** la boîte précise qu'aucun sondé n'a répondu et que l'action est définitive

#### Scenario: Retrait
- **WHEN** le manager ferme la boîte avec « Non, revenir »
- **THEN** la campagne est conservée

#### Scenario: Campagne en cours
- **WHEN** un manager ouvre la page d'une de ses campagnes en cours
- **THEN** aucun bouton de suppression n'est affiché
