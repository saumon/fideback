# Spec Delta

## Purpose

Permettre à l'Admin d'inviter une personne précise à devenir manager, par un lien personnel et limité dans le temps, y compris quand les inscriptions sont fermées.

## ADDED Requirements

### Requirement: Invitation d'un manager par l'Admin
Le système SHALL permettre à l'Admin de saisir le nom et l'adresse e-mail d'une personne depuis l'écran des utilisateurs, et de lui envoyer une invitation à devenir manager. Cette fonction SHALL être disponible que les inscriptions soient ouvertes ou fermées, et réservée à l'Admin : tout autre manager connecté reçoit une page introuvable (404), et un visiteur est redirigé vers la connexion.

#### Scenario: Bouton d'invitation
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** l'écran contient un bouton « Inviter un manager » qui mène au formulaire d'invitation

#### Scenario: Invitation envoyée
- **WHEN** l'Admin saisit un nom et une adresse e-mail valides, sans compte ni invitation existante, et valide
- **THEN** une invitation est créée, un e-mail est envoyé à cette adresse, l'Admin revient à l'écran des utilisateurs et une notice confirme l'envoi

#### Scenario: Inscriptions fermées
- **WHEN** l'Admin invite une personne alors que les inscriptions sont fermées
- **THEN** l'invitation est créée et envoyée normalement

#### Scenario: Accès par un manager non Admin
- **WHEN** un manager connecté sans le rôle `admin` ouvre le formulaire d'invitation ou tente d'inviter, de renvoyer ou d'annuler une invitation
- **THEN** la réponse est une page introuvable (404) et rien n'est créé ni modifié

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté ouvre le formulaire d'invitation
- **THEN** il est redirigé vers la page de connexion

### Requirement: Validation de l'invitation
Le système SHALL exiger un nom et une adresse e-mail valide, SHALL refuser l'invitation d'une adresse qui a déjà un compte, quelle que soit l'activation de ce compte, et SHALL remplacer l'invitation non acceptée déjà adressée à la même adresse, sans distinguer majuscules et minuscules. Une invitation refusée SHALL NOT être créée ni envoyée.

#### Scenario: Champs manquants ou invalides
- **WHEN** l'Admin valide le formulaire sans nom, sans e-mail ou avec une adresse mal formée
- **THEN** le formulaire est réaffiché avec une erreur sur chaque champ concerné, et aucune invitation n'est créée

#### Scenario: Adresse déjà inscrite
- **WHEN** l'Admin invite une adresse qui a déjà un compte manager
- **THEN** le formulaire est réaffiché avec une erreur sur l'adresse, aucune invitation n'est créée et aucun e-mail n'est envoyé

#### Scenario: Adresse déjà invitée
- **WHEN** l'Admin invite une adresse à laquelle une invitation non acceptée a déjà été adressée
- **THEN** l'invitation précédente est remplacée par une nouvelle, son ancien lien cesse de fonctionner et un nouvel e-mail est envoyé

### Requirement: E-mail d'invitation
Le système SHALL envoyer à l'invité un e-mail, en version HTML dans l'habillage commun et en version texte, qui le salue par son nom, indique qui l'invite, présente un bouton « Accepter l'invitation » menant au lien d'acceptation, donne l'adresse complète du lien en version texte, et précise la date limite de validité ainsi que le caractère personnel du lien.

#### Scenario: Contenu de l'e-mail
- **WHEN** l'Admin Alice Manager invite Pat Durand
- **THEN** Pat reçoit un e-mail qui commence par « Bonjour Pat Durand, », nomme Alice Manager, contient le lien d'acceptation dans ses deux versions et indique la date limite de validité

#### Scenario: Expéditeur
- **WHEN** une invitation est envoyée
- **THEN** l'e-mail part de l'expéditeur unique de l'application, comme les autres e-mails

### Requirement: Validité de l'invitation
Le système SHALL limiter la validité d'une invitation à 7 jours à compter de son envoi ou de son dernier renvoi. Passé ce délai, l'invitation SHALL ne plus pouvoir être acceptée.

#### Scenario: Invitation valable
- **WHEN** l'invité ouvre son lien dans les 7 jours
- **THEN** la page d'acceptation s'affiche

#### Scenario: Invitation expirée
- **WHEN** l'invité ouvre son lien plus de 7 jours après l'envoi
- **THEN** la page d'invitation expirée s'affiche et aucun compte ne peut être créé par ce lien

### Requirement: Acceptation de l'invitation
Le système SHALL afficher à l'invité, depuis son lien, une page d'acceptation avec son nom pré-rempli et modifiable, son adresse e-mail non modifiable, un mot de passe et sa confirmation. À la validation, il SHALL créer le compte avec le rôle `manager`, déjà activé et sans e-mail d'activation, consommer l'invitation, et renvoyer l'invité vers la connexion avec un message, sans le connecter.

#### Scenario: Acceptation valide
- **WHEN** l'invité choisit un mot de passe valide, confirmé, et valide la page d'acceptation
- **THEN** un compte manager activé est créé avec son nom et l'adresse invitée, aucun e-mail d'activation n'est envoyé, l'invitation ne peut plus servir, et il est renvoyé vers la page de connexion avec un message de confirmation sans être connecté

#### Scenario: Inscriptions fermées
- **WHEN** l'invité accepte son invitation alors que les inscriptions sont fermées
- **THEN** le compte est créé normalement

#### Scenario: Mot de passe invalide
- **WHEN** l'invité valide un mot de passe trop court ou une confirmation différente
- **THEN** la page d'acceptation est réaffichée avec les erreurs, son nom saisi est conservé et aucun compte n'est créé

#### Scenario: Nom modifié
- **WHEN** l'invité corrige son nom avant de valider
- **THEN** le compte créé porte le nom corrigé

#### Scenario: Manager déjà connecté
- **WHEN** un manager connecté ouvre un lien d'invitation
- **THEN** il est renvoyé vers ses campagnes avec un message indiquant qu'il est déjà connecté, et aucun compte n'est créé

### Requirement: Lien d'invitation invalide
Le système SHALL afficher une page explicative, qui renvoie vers l'administrateur pour obtenir une nouvelle invitation, lorsque le lien est inconnu, expiré, annulé, remplacé ou déjà utilisé, ou que son adresse a entre-temps obtenu un compte. Aucun compte SHALL être créé par un tel lien.

#### Scenario: Lien déjà utilisé
- **WHEN** l'invité ouvre à nouveau son lien après avoir créé son compte
- **THEN** la page explicative s'affiche

#### Scenario: Lien annulé ou remplacé
- **WHEN** l'invité ouvre le lien d'une invitation annulée ou remplacée par un renvoi
- **THEN** la page explicative s'affiche

#### Scenario: Adresse devenue inscrite
- **WHEN** l'invité ouvre son lien alors que son adresse a obtenu un compte par une autre voie
- **THEN** la page explicative s'affiche et aucun second compte n'est créé

### Requirement: Suivi des invitations
Le système SHALL lister sur l'écran des utilisateurs les invitations non acceptées, de la plus récente à la plus ancienne, avec le nom, l'adresse, la date d'envoi et un état « En attente » ou « Expirée ». Une invitation acceptée SHALL NOT figurer dans cette liste. Sans invitation, un message le dit.

#### Scenario: Invitations listées
- **WHEN** l'Admin ouvre l'écran des utilisateurs alors qu'une invitation est en attente et une autre expirée
- **THEN** le bloc « Invitations en attente » affiche les deux, chacune avec son état

#### Scenario: Invitation acceptée
- **WHEN** un invité a accepté son invitation
- **THEN** elle ne figure plus dans le bloc et la personne apparaît dans la liste des managers

#### Scenario: Aucune invitation
- **WHEN** l'Admin ouvre l'écran alors qu'aucune invitation n'est en cours
- **THEN** le bloc indique qu'aucune invitation n'est en attente

### Requirement: Renvoi d'une invitation
Le système SHALL permettre à l'Admin de renvoyer une invitation non acceptée, en attente ou expirée : un nouveau lien est créé, la validité de 7 jours repart de zéro, un nouvel e-mail est envoyé et l'ancien lien cesse de fonctionner.

#### Scenario: Renvoi d'une invitation expirée
- **WHEN** l'Admin renvoie une invitation expirée
- **THEN** l'invitation repasse « En attente », un nouvel e-mail est envoyé, une notice confirme le renvoi, et le nouveau lien fonctionne tandis que l'ancien ne fonctionne plus

### Requirement: Annulation d'une invitation
Le système SHALL permettre à l'Admin d'annuler une invitation non acceptée. L'invitation SHALL disparaître du suivi et son lien SHALL cesser de fonctionner.

#### Scenario: Annulation
- **WHEN** l'Admin annule une invitation en attente
- **THEN** elle disparaît du bloc, une notice confirme l'annulation et son lien mène à la page explicative
