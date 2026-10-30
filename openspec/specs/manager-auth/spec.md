# manager-auth Specification

## Purpose

Permettre aux managers de disposer d'un compte personnel sécurisé afin que seuls les utilisateurs authentifiés accèdent à leurs campagnes et aux feedbacks associés.

## Requirements

### Requirement: Inscription d'un manager
Le système SHALL permettre à un visiteur de créer un compte manager avec un nom, un e-mail unique et un mot de passe. Le compte créé SHALL être inactif tant que l'adresse e-mail n'a pas été validée, et l'inscription SHALL NOT ouvrir de session.

#### Scenario: Inscription valide
- **WHEN** un visiteur soumet un nom, un e-mail inconnu et un mot de passe valide
- **THEN** un compte inactif est créé, un e-mail d'activation est envoyé à cette adresse, le visiteur n'est pas connecté et il est redirigé vers la page de connexion avec un message l'invitant à consulter sa boîte mail

#### Scenario: E-mail déjà utilisé
- **WHEN** un visiteur soumet un e-mail déjà associé à un compte
- **THEN** aucun compte n'est créé, aucun e-mail n'est envoyé et une erreur est affichée

### Requirement: Connexion et déconnexion
Le système SHALL authentifier un manager par e-mail et mot de passe et lui permettre de se déconnecter.

#### Scenario: Identifiants valides
- **WHEN** un manager soumet un e-mail et un mot de passe corrects
- **THEN** il est connecté et redirigé vers la liste de ses campagnes

#### Scenario: Identifiants invalides
- **WHEN** un manager soumet un mot de passe incorrect
- **THEN** il reste non connecté et un message d'erreur générique est affiché

#### Scenario: Déconnexion
- **WHEN** un manager connecté se déconnecte
- **THEN** sa session est terminée et il est redirigé vers la page de connexion

### Requirement: Réinitialisation du mot de passe
Le système SHALL permettre à un manager de réinitialiser son mot de passe via un lien envoyé par e-mail.

#### Scenario: Demande de réinitialisation
- **WHEN** un manager saisit l'e-mail de son compte sur la page de mot de passe oublié
- **THEN** un e-mail contenant un lien de réinitialisation à durée limitée lui est envoyé

#### Scenario: E-mail inconnu
- **WHEN** un visiteur saisit un e-mail sans compte
- **THEN** la réponse affichée est identique à celle d'un e-mail connu, sans révéler l'existence du compte

#### Scenario: Bouton de demande lisible
- **WHEN** un visiteur ouvre la page de mot de passe oublié, sur ordinateur ou sur un écran de téléphone de 360 px de large
- **THEN** le bouton d'envoi s'intitule « Envoyez-moi les instructions » et tient entièrement dans la carte du formulaire, sans texte coupé

### Requirement: Accès réservé aux managers authentifiés
Le système SHALL refuser l'accès aux pages de gestion de campagnes à tout visiteur non authentifié.

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté demande la liste des campagnes
- **THEN** il est redirigé vers la page de connexion

### Requirement: Activation du compte par lien
Le système SHALL activer un compte manager lorsque le lien reçu par e-mail est suivi, pendant 24 heures après son envoi, puis rediriger vers la page de connexion sans ouvrir de session.

#### Scenario: Lien valide
- **WHEN** un visiteur suit un lien d'activation valide et non expiré
- **THEN** le compte est activé, le visiteur n'est pas connecté et il est redirigé vers la page de connexion avec un message de confirmation

#### Scenario: Lien déjà utilisé
- **WHEN** un visiteur suit le lien d'activation d'un compte déjà activé
- **THEN** il reste sur la page de renvoi, un message indique que le compte est déjà actif et un lien vers la connexion est proposé

### Requirement: Lien d'activation invalide
Le système SHALL distinguer pour le visiteur les trois cas d'échec d'un lien d'activation (expiré, compte déjà actif, lien inconnu) et lui proposer de demander un nouvel e-mail.

#### Scenario: Lien expiré
- **WHEN** un visiteur suit un lien d'activation envoyé il y a plus de 24 heures
- **THEN** le compte reste inactif et la page de renvoi s'affiche avec un message indiquant que le lien a expiré

#### Scenario: Lien inconnu
- **WHEN** un visiteur suit un lien d'activation qui ne correspond à aucun compte, y compris un lien remplacé par un renvoi plus récent
- **THEN** la page de renvoi s'affiche avec un message indiquant que le lien n'est pas reconnu

### Requirement: Connexion refusée tant que le compte n'est pas activé
Le système SHALL refuser la connexion d'un manager dont le compte n'est pas activé, sans révéler à un tiers l'état d'un compte.

#### Scenario: Compte inactif, bon mot de passe
- **WHEN** un manager au compte inactif soumet son e-mail et son mot de passe corrects
- **THEN** il reste non connecté et un message lui indique qu'il doit activer son compte via le lien reçu par e-mail

#### Scenario: Compte inactif, mauvais mot de passe
- **WHEN** quelqu'un soumet l'e-mail d'un compte inactif avec un mot de passe incorrect
- **THEN** le message affiché est le message d'erreur générique des identifiants invalides, identique à celui d'un compte actif

### Requirement: Renvoi de l'e-mail d'activation
Le système SHALL permettre de demander un nouvel e-mail d'activation depuis une page dédiée, avec une réponse identique quelle que soit l'adresse saisie, et au plus un e-mail par adresse toutes les 5 minutes. Chaque nouvel e-mail SHALL invalider les liens d'activation précédents.

#### Scenario: Renvoi pour un compte inactif
- **WHEN** un visiteur saisit l'e-mail d'un compte inactif dont le dernier e-mail d'activation date de plus de 5 minutes
- **THEN** un nouvel e-mail d'activation est envoyé et les liens des e-mails précédents cessent de fonctionner

#### Scenario: Demandes rapprochées
- **WHEN** un visiteur redemande un e-mail d'activation pour une adresse moins de 5 minutes après le dernier envoi
- **THEN** aucun e-mail n'est envoyé

#### Scenario: Adresse inconnue ou compte déjà actif
- **WHEN** un visiteur saisit une adresse sans compte, ou celle d'un compte déjà activé
- **THEN** aucun e-mail n'est envoyé

#### Scenario: Réponse indistinguable
- **WHEN** un visiteur demande un e-mail d'activation, que l'adresse soit inconnue, active, inactive ou limitée par le délai de 5 minutes
- **THEN** la page et le message affichés sont identiques dans tous les cas

#### Scenario: Lien de retour à la connexion
- **WHEN** un visiteur ouvre la page de demande d'un nouvel e-mail d'activation, sur ordinateur ou sur un écran de téléphone
- **THEN** le lien « Retour à la connexion » mène à la page de connexion, et il est séparé de la carte du formulaire et écrit à la même taille que les liens de la page de mot de passe oublié

### Requirement: Comptes existants considérés comme activés
Le système SHALL considérer comme activés tous les comptes manager créés avant l'introduction de l'activation par e-mail.

#### Scenario: Manager existant après mise en production
- **WHEN** un manager qui avait un compte avant la mise en production de l'activation se connecte avec ses identifiants
- **THEN** il est connecté normalement, sans devoir activer son compte

### Requirement: Premier compte créé administrateur
Le système SHALL attribuer le rôle `admin` au compte manager créé à l'inscription lorsqu'aucun manager n'existe encore, que son adresse e-mail soit activée ou non. Aucun autre compte SHALL recevoir ce rôle à l'inscription, y compris après la suppression de l'Admin.

#### Scenario: Première inscription
- **WHEN** un visiteur s'inscrit alors qu'aucun manager n'existe
- **THEN** le compte créé a le rôle `admin`

#### Scenario: Inscriptions suivantes
- **WHEN** un visiteur s'inscrit alors qu'au moins un manager existe
- **THEN** le compte créé a le rôle `manager`

#### Scenario: Admin supprimé
- **WHEN** l'Admin supprime son compte alors que d'autres managers existent, puis un visiteur s'inscrit
- **THEN** le nouveau compte a le rôle `manager` et plus aucun Admin n'existe

#### Scenario: Inscriptions simultanées
- **WHEN** deux visiteurs s'inscrivent au même moment alors qu'aucun manager n'existe
- **THEN** un seul des deux comptes reçoit le rôle `admin`

### Requirement: Comptes existants et premier administrateur
Le système SHALL, lors de l'introduction des rôles, attribuer le rôle `admin` au manager existant le plus ancien et le rôle `manager` à tous les autres.

#### Scenario: Base existante
- **WHEN** les rôles sont introduits alors que plusieurs managers existent
- **THEN** le manager créé en premier devient `admin` et les autres sont `manager`

#### Scenario: Base vide
- **WHEN** les rôles sont introduits alors qu'aucun manager n'existe
- **THEN** aucun Admin n'est créé et la prochaine inscription devient `admin`
