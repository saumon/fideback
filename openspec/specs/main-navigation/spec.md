# main-navigation Specification

## Purpose

Indiquer dans la navigation principale l'entrée qui correspond à l'écran ouvert, pour que l'on sache toujours où l'on se trouve dans l'application.

## Requirements

### Requirement: Entrée de la section courante signalée
Le système SHALL signaler dans la navigation principale l'unique entrée qui correspond à l'écran ouvert, en l'identifiant comme page courante pour les technologies d'assistance et en la distinguant visuellement des autres entrées. Les autres entrées SHALL NOT être signalées.

#### Scenario: Écran des campagnes
- **WHEN** un manager connecté ouvre la liste de ses campagnes
- **THEN** l'entrée « Mes campagnes » est signalée comme page courante et aucune autre entrée ne l'est

#### Scenario: Écran de l'équipe
- **WHEN** un manager connecté ouvre l'écran de son équipe
- **THEN** l'entrée « Mon équipe » est signalée comme page courante

#### Scenario: Écran d'administration
- **WHEN** un Admin connecté ouvre l'écran d'administration
- **THEN** l'entrée « Administration » est signalée comme page courante

#### Scenario: Page de connexion
- **WHEN** un visiteur non connecté ouvre la page de connexion
- **THEN** l'entrée « Se connecter » est signalée comme page courante

### Requirement: Signalement par section
Le système SHALL signaler l'entrée de la section à laquelle appartient l'écran ouvert, et non seulement celle dont l'adresse est identique à l'écran ouvert.

#### Scenario: Écran d'une campagne
- **WHEN** un manager connecté ouvre la création, le détail, l'édition d'une campagne ou la synthèse d'une personne évaluée
- **THEN** l'entrée « Mes campagnes » est signalée comme page courante

#### Scenario: Écran des utilisateurs
- **WHEN** un Admin connecté ouvre l'écran des utilisateurs
- **THEN** l'entrée « Administration » est signalée comme page courante

#### Scenario: Compte du manager
- **WHEN** un manager connecté ouvre la page de son compte, ou que la modification de son compte est refusée et le formulaire réaffiché
- **THEN** l'entrée portant son nom est signalée comme page courante

### Requirement: Aucune entrée signalée hors du menu
Le système SHALL n'afficher aucune entrée signalée sur un écran qui n'a pas d'entrée dans la navigation principale.

#### Scenario: Page introuvable
- **WHEN** un manager connecté ouvre une adresse inexistante
- **THEN** la navigation s'affiche sans entrée signalée

#### Scenario: Espace d'un sondé
- **WHEN** un sondé ouvre son lien personnel
- **THEN** la navigation s'affiche sans entrée signalée

#### Scenario: Création de compte
- **WHEN** un visiteur ouvre la page de création de compte
- **THEN** la navigation s'affiche sans entrée signalée, le bouton « Créer un compte » n'étant pas une entrée de menu

### Requirement: Surlignage stable et animé
Le système SHALL présenter l'entrée signalée en gras, soulignée d'une barre épaisse multicolore, sans que la navigation change de taille ou de position d'un écran à l'autre. La barre SHALL se dérouler quand l'écran s'ouvre, puis ses couleurs SHALL défiler en boucle tant que l'écran reste ouvert.

#### Scenario: Navigation stable
- **WHEN** un manager passe d'un écran à un autre
- **THEN** les entrées de la navigation gardent la même place et la même taille

#### Scenario: Ouverture d'un écran
- **WHEN** un manager clique sur une entrée du menu et que l'écran correspondant s'ouvre
- **THEN** la barre sous l'entrée signalée se déroule de gauche à droite

#### Scenario: Écran resté ouvert
- **WHEN** un écran reste ouvert après l'ouverture de la barre
- **THEN** les couleurs de la barre défilent en continu

### Requirement: Mouvement réduit
Lorsque l'utilisateur demande moins de mouvement, le système SHALL afficher la barre de l'entrée signalée entièrement déroulée et immobile, sans aucune animation.

#### Scenario: Mouvement réduit
- **WHEN** un utilisateur ayant demandé moins de mouvement ouvre un écran
- **THEN** la barre sous l'entrée signalée est affichée complète, sans animation d'ouverture ni défilement
