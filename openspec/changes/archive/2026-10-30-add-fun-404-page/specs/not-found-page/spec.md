# Spec Delta

## Purpose

Donner aux pages introuvables un visage fidèle à l'identité de Fideback, drôle et utile : le visiteur comprend qu'il s'est égaré et sait où retourner.

## ADDED Requirements

### Requirement: Page 404 pour toute adresse inconnue
Le système SHALL répondre par le statut 404 et une page dédiée à toute adresse qui ne correspond à aucune page, et à toute page dont l'enregistrement demandé n'existe pas, quelle que soit la méthode de la requête.

#### Scenario: Adresse inconnue
- **WHEN** un visiteur demande une adresse que l'application ne connaît pas
- **THEN** la réponse a le statut 404 et affiche la page introuvable de Fideback

#### Scenario: Enregistrement inexistant
- **WHEN** un manager demande une campagne qui n'existe pas ou qui ne lui appartient pas
- **THEN** la réponse a le statut 404 et affiche la même page

#### Scenario: Espace d'administration refusé
- **WHEN** un manager qui n'est pas Admin ouvre l'espace d'administration
- **THEN** la réponse a le statut 404 et affiche la même page, sans rien révéler de l'existence de l'espace

### Requirement: Page dans le style du site
La page introuvable SHALL reprendre l'identité visuelle de Fideback : sa barre du haut, sa police, ses couleurs et ses animations. Les animations MUST s'arrêter pour un visiteur qui demande moins de mouvement, sans que la page perde un contenu.

#### Scenario: Habillage du site
- **WHEN** un visiteur arrive sur une page introuvable
- **THEN** la page affiche la barre du haut et la feuille de style de Fideback, et non une page autonome

#### Scenario: Mouvement réduit
- **WHEN** un visiteur dont le système demande moins de mouvement arrive sur une page introuvable
- **THEN** aucune animation ne se joue et tout le texte reste visible

### Requirement: Ton drôle et page lisible
La page introuvable SHALL annoncer clairement, en français, que la page n'existe pas (le code 404 y figure) sur un ton humoristique inspiré de l'univers de Fideback. Le texte MUST rester compréhensible pour un lecteur d'écran, et l'humour MUST NOT mettre en cause le visiteur ni se faire passer pour un vrai feedback sur une personne.

#### Scenario: Message clair
- **WHEN** un visiteur arrive sur une page introuvable
- **THEN** le titre de la page et son contenu disent que la page est introuvable et le code 404 est visible

#### Scenario: Lecture par un lecteur d'écran
- **WHEN** un lecteur d'écran lit la page
- **THEN** il annonce le titre et le message d'erreur une seule fois, sans lire d'éléments purement décoratifs

### Requirement: Retour proposé
La page introuvable SHALL proposer un lien de retour : vers la liste des campagnes pour un manager connecté, vers l'accueil sinon. Pour une adresse de l'espace des sondés, elle MUST NOT proposer de lien de création de compte ni de connexion.

#### Scenario: Manager connecté
- **WHEN** un manager connecté arrive sur une page introuvable
- **THEN** la page lui propose de retourner à ses campagnes et la navigation reste celle d'un manager connecté

#### Scenario: Visiteur non connecté
- **WHEN** un visiteur non connecté arrive sur une page introuvable
- **THEN** la page lui propose de retourner à l'accueil

#### Scenario: Espace des sondés
- **WHEN** un sondé suit un lien personnel inconnu ou incomplet
- **THEN** la page introuvable s'affiche sans lien de connexion ni de création de compte

### Requirement: Page de secours
Le système SHALL conserver une page 404 autonome, servie si la page dynamique ne peut pas être produite, de sorte qu'un visiteur ne reçoive jamais une erreur technique à la place.

#### Scenario: Secours
- **WHEN** la page introuvable habillée ne peut pas être rendue
- **THEN** la page 404 autonome est servie avec le statut 404
