# admin-users Specification

## Purpose

Donner à l'Admin du site une vue des managers inscrits, y compris ceux qui n'ont pas encore activé leur compte, le moyen d'inviter de nouveaux managers et celui de supprimer un manager, sans autre modification des comptes existants.

## Requirements

### Requirement: Écran des utilisateurs réservé à l'Admin
Le système SHALL n'autoriser l'accès à l'écran des utilisateurs qu'à un manager connecté ayant le rôle `admin`. Pour tout autre manager connecté, il SHALL répondre comme si la page n'existait pas.

#### Scenario: Accès par un Admin
- **WHEN** un Admin connecté ouvre l'écran des utilisateurs
- **THEN** l'écran titré « Utilisateurs » s'affiche

#### Scenario: Accès par un manager non Admin
- **WHEN** un manager connecté sans le rôle `admin` ouvre l'écran des utilisateurs
- **THEN** la réponse est une page introuvable (404), identique à celle d'une adresse inexistante

#### Scenario: Accès anonyme
- **WHEN** un visiteur non connecté ouvre l'écran des utilisateurs
- **THEN** il est redirigé vers la page de connexion

### Requirement: Liste des managers inscrits
Le système SHALL lister sur l'écran des utilisateurs tous les managers inscrits, avec pour chacun son nom, son e-mail, son rôle (« Manager » ou « Admin ») et sa date d'inscription.

#### Scenario: Contenu d'une ligne
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** chaque manager inscrit apparaît une fois, avec son nom, son e-mail, son rôle et sa date d'inscription

#### Scenario: Rôles affichés
- **WHEN** la liste contient un Admin et un manager
- **THEN** le premier est présenté comme « Admin » et le second comme « Manager »

### Requirement: Comptes non confirmés signalés
Le système SHALL inclure dans la liste les managers qui n'ont pas encore confirmé leur compte et SHALL les signaler par un badge « Non confirmé ». Un compte confirmé SHALL NOT porter ce badge.

#### Scenario: Compte non confirmé
- **WHEN** un manager inscrit n'a pas cliqué sur son lien d'activation
- **THEN** il figure dans la liste avec le badge « Non confirmé »

#### Scenario: Compte confirmé
- **WHEN** un manager a confirmé son compte
- **THEN** il figure dans la liste sans badge « Non confirmé »

### Requirement: Ordre de la liste
Le système SHALL trier la liste des utilisateurs par date d'inscription décroissante, le plus récent en premier.

#### Scenario: Tri par inscription
- **WHEN** trois managers se sont inscrits à des dates différentes
- **THEN** le plus récemment inscrit apparaît en premier et le plus ancien en dernier

### Requirement: Actions de l'écran limitées
Le système SHALL limiter les actions de l'écran des utilisateurs à l'invitation de nouveaux managers, au suivi des invitations et à la suppression d'un manager, sans aucune autre action sur les comptes existants (pas de changement de rôle ni de modification), et SHALL y offrir un lien de retour vers l'écran « Administration ».

#### Scenario: Aucune action sur les comptes
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** l'écran ne propose aucun changement de rôle ni aucune modification sur les comptes de la liste des managers, seulement la suppression des managers autres que l'Admin connecté

#### Scenario: Actions sur les invitations
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** l'écran propose le bouton « Inviter un manager » et, pour chaque invitation non acceptée, « Renvoyer » et « Annuler »

#### Scenario: Retour à l'administration
- **WHEN** un Admin suit le lien de retour de l'écran des utilisateurs
- **THEN** l'écran « Administration » s'affiche

### Requirement: Suppression d'un manager avec confirmation
Le système SHALL proposer à l'Admin, sur la ligne de chaque manager autre que lui-même, une action « Supprimer » qui ne supprime le compte qu'après une confirmation explicite annonçant que les campagnes du manager, avec le nombre de campagnes, et toutes les réponses recueillies seront effacées. Annuler la confirmation SHALL laisser le compte intact.

#### Scenario: Suppression confirmée
- **WHEN** l'Admin demande la suppression d'un manager puis la confirme
- **THEN** le manager disparaît de la liste, l'écran des utilisateurs s'affiche avec une notice confirmant la suppression, et il ne peut plus se connecter

#### Scenario: Suppression annulée
- **WHEN** l'Admin demande la suppression d'un manager puis l'annule
- **THEN** le manager reste dans la liste et rien n'est supprimé

#### Scenario: Confirmation annonçant l'ampleur
- **WHEN** l'Admin demande la suppression d'un manager qui a deux campagnes
- **THEN** la confirmation indique que ses deux campagnes et toutes les réponses recueillies seront effacées

#### Scenario: Manager non confirmé
- **WHEN** l'Admin supprime un manager qui n'a pas confirmé son compte
- **THEN** le manager est supprimé comme n'importe quel autre

### Requirement: Effets de la suppression d'un manager
Le système SHALL supprimer avec le manager ses campagnes, quel que soit leur état, avec leurs questions, sondés et réponses, ainsi que son annuaire de contacts et ses liens de connexion, et SHALL conserver les invitations qu'il a envoyées. Il SHALL NOT envoyer d'e-mail au manager supprimé.

#### Scenario: Campagnes et réponses effacées
- **WHEN** l'Admin supprime un manager qui a une campagne lancée avec des réponses de sondés
- **THEN** la campagne, ses sondés et leurs réponses n'existent plus, et les liens personnels de ces sondés mènent à une page introuvable

#### Scenario: Annuaire et liens de connexion effacés
- **WHEN** l'Admin supprime un manager qui a des contacts et un lien de connexion en cours
- **THEN** ses contacts et ses liens de connexion n'existent plus

#### Scenario: Invitations envoyées conservées
- **WHEN** l'Admin supprime un manager qui avait invité d'autres personnes
- **THEN** ces invitations restent présentes, y compris celles encore en attente, qui figurent toujours dans la liste des invitations

#### Scenario: Aucun e-mail
- **WHEN** l'Admin supprime un manager
- **THEN** aucun e-mail n'est envoyé au manager supprimé

#### Scenario: Adresse réutilisable
- **WHEN** l'Admin a supprimé un manager
- **THEN** son adresse e-mail peut de nouveau être invitée et inscrite

### Requirement: Session du manager supprimé invalidée
Le système SHALL cesser de reconnaître un manager supprimé : sa session ouverte, y compris par le cookie « Se souvenir de moi », ne donne plus accès à rien, et la prochaine page qu'il demande le renvoie vers la page de connexion.

#### Scenario: Session ouverte
- **WHEN** un manager est connecté dans un navigateur et que l'Admin le supprime, puis qu'il ouvre une page réservée aux managers
- **THEN** il est redirigé vers la page de connexion

### Requirement: Auto-suppression de l'Admin interdite
Le système SHALL NOT permettre à l'Admin connecté de supprimer son propre compte : sa ligne ne propose aucune action « Supprimer », et toute requête de suppression visant son compte est refusée, avec un message d'erreur, sans rien supprimer.

#### Scenario: Pas d'action sur sa propre ligne
- **WHEN** un Admin ouvre l'écran des utilisateurs
- **THEN** sa ligne ne propose pas « Supprimer » alors que celle de chaque autre manager le propose

#### Scenario: Requête visant son propre compte
- **WHEN** un Admin envoie une requête de suppression visant son propre compte
- **THEN** la requête est refusée avec un message d'erreur, son compte, ses campagnes et sa session sont intacts

### Requirement: Suppression réservée à l'Admin
Le système SHALL n'accepter une suppression de manager que d'un Admin connecté. Pour tout autre manager connecté, il SHALL répondre comme si la page n'existait pas, sans rien supprimer ; un visiteur non connecté SHALL être redirigé vers la page de connexion.

#### Scenario: Tentative par un manager non Admin
- **WHEN** un manager sans le rôle `admin` envoie une requête de suppression d'un manager
- **THEN** la réponse est une page introuvable (404) et rien n'est supprimé

#### Scenario: Tentative anonyme
- **WHEN** un visiteur non connecté envoie une requête de suppression d'un manager
- **THEN** il est redirigé vers la page de connexion et rien n'est supprimé

### Requirement: Manager déjà supprimé
Le système SHALL répondre par une page introuvable (404) à une demande de suppression visant un manager qui n'existe plus, sans rien modifier.

#### Scenario: Double suppression
- **WHEN** l'Admin demande la suppression d'un manager déjà supprimé, par exemple depuis un second onglet
- **THEN** la réponse est une page introuvable (404)
