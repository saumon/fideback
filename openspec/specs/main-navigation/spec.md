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
Le système SHALL présenter l'entrée signalée en gras, soulignée d'une barre épaisse multicolore, sans que la navigation change de taille ou de position d'un écran à l'autre. La barre SHALL se dérouler quand l'écran s'ouvre, puis ses couleurs SHALL défiler en boucle tant que l'écran reste ouvert. Dans le tiroir, la barre SHALL se dérouler à chaque ouverture du tiroir.

#### Scenario: Navigation stable
- **WHEN** un manager passe d'un écran à un autre
- **THEN** les entrées de la navigation gardent la même place et la même taille

#### Scenario: Ouverture d'un écran
- **WHEN** un manager clique sur une entrée du menu et que l'écran correspondant s'ouvre
- **THEN** la barre sous l'entrée signalée se déroule de gauche à droite

#### Scenario: Écran resté ouvert
- **WHEN** un écran reste ouvert après l'ouverture de la barre
- **THEN** les couleurs de la barre défilent en continu

#### Scenario: Ouverture du tiroir
- **WHEN** un manager ouvre le tiroir sur un écran étroit
- **THEN** la barre sous l'entrée signalée se déroule, puis ses couleurs défilent en continu tant que le tiroir reste ouvert

### Requirement: Mouvement réduit
Lorsque l'utilisateur demande moins de mouvement, le système SHALL afficher la barre de l'entrée signalée entièrement déroulée et immobile, sans aucune animation, et SHALL ouvrir et fermer le tiroir sans glissement ni cascade.

#### Scenario: Mouvement réduit
- **WHEN** un utilisateur ayant demandé moins de mouvement ouvre un écran
- **THEN** la barre sous l'entrée signalée est affichée complète, sans animation d'ouverture ni défilement

#### Scenario: Tiroir avec mouvement réduit
- **WHEN** un utilisateur ayant demandé moins de mouvement ouvre ou ferme le tiroir
- **THEN** le tiroir apparaît et disparaît sans glissement et ses entrées sont affichées sans cascade

### Requirement: Menu mobile en tiroir
Sur un écran étroit, le système SHALL remplacer la navigation horizontale par un bouton de menu dans l'en-tête, qui ouvre un tiroir latéral contenant les entrées de la navigation. Sur un écran large, la navigation horizontale SHALL rester affichée.

#### Scenario: En-tête sur écran étroit
- **WHEN** un manager connecté ouvre un écran sur un écran étroit
- **THEN** l'en-tête n'affiche que le logo et le bouton de menu, sur une seule ligne, et les entrées de navigation ne sont pas affichées tant que le tiroir est fermé

#### Scenario: Contenu du tiroir d'un manager
- **WHEN** un manager connecté ouvre le tiroir sur un écran étroit
- **THEN** le tiroir présente ses entrées de navigation, puis, séparés d'elles, le nom du manager et « Se déconnecter »

#### Scenario: Contenu du tiroir d'un visiteur
- **WHEN** un visiteur ouvre le tiroir sur un écran étroit
- **THEN** le tiroir présente « Se connecter »

#### Scenario: Créer un compte reste visible
- **WHEN** un visiteur consulte un écran sur un écran étroit, tiroir fermé
- **THEN** le bouton « Créer un compte » est affiché dans l'en-tête, à côté du bouton de menu

#### Scenario: Écran large
- **WHEN** un manager connecté ouvre un écran sur un écran large
- **THEN** la navigation horizontale est affichée et le bouton de menu ne l'est pas

### Requirement: Ouverture et fermeture du tiroir
Le système SHALL ouvrir le tiroir par le bouton de menu, qui se change en croix pendant l'ouverture, avec un fond assombri derrière le tiroir. Le système SHALL fermer le tiroir par le bouton, par la touche Échap, par un clic sur le fond assombri ou par un clic sur une entrée de navigation.

#### Scenario: Ouverture
- **WHEN** l'utilisateur active le bouton de menu
- **THEN** le tiroir s'ouvre depuis le bord droit, le fond s'assombrit et le bouton devient une croix

#### Scenario: Fermeture par Échap
- **WHEN** le tiroir est ouvert et l'utilisateur appuie sur Échap
- **THEN** le tiroir se ferme

#### Scenario: Fermeture par le fond
- **WHEN** le tiroir est ouvert et l'utilisateur clique sur le fond assombri
- **THEN** le tiroir se ferme

#### Scenario: Navigation depuis le tiroir
- **WHEN** l'utilisateur clique sur une entrée du tiroir
- **THEN** l'écran correspondant s'ouvre et le tiroir est fermé

#### Scenario: Retour dans l'historique
- **WHEN** l'utilisateur revient à un écran précédent après avoir ouvert le tiroir
- **THEN** l'écran s'affiche avec le tiroir fermé

### Requirement: Accessibilité du tiroir
Le système SHALL annoncer l'état ouvert ou fermé du tiroir sur le bouton de menu, SHALL maintenir le focus clavier dans le tiroir tant qu'il est ouvert, SHALL rendre le reste de la page inerte et SHALL empêcher son défilement. À la fermeture, le système SHALL rendre le focus au bouton de menu.

#### Scenario: État annoncé
- **WHEN** le tiroir est ouvert ou fermé
- **THEN** le bouton de menu indique s'il est développé et son nom accessible reflète l'action (« Ouvrir le menu » ou « Fermer le menu »)

#### Scenario: Focus maintenu
- **WHEN** le tiroir est ouvert et l'utilisateur parcourt les éléments avec la touche Tab
- **THEN** le focus reste parmi le bouton de menu et les éléments du tiroir, sans atteindre le reste de la page

#### Scenario: Retour du focus
- **WHEN** le tiroir se ferme
- **THEN** le focus est rendu au bouton de menu

### Requirement: Navigation sans JavaScript
Lorsque JavaScript n'est pas disponible, le système SHALL afficher les entrées de navigation sans tiroir, empilées dans l'en-tête, de sorte que toutes restent accessibles.

#### Scenario: Sans JavaScript sur écran étroit
- **WHEN** un manager connecté ouvre un écran sur un écran étroit sans JavaScript
- **THEN** toutes les entrées de navigation sont affichées et utilisables, sans bouton de menu

### Requirement: Entrée des modèles de questions
Le système SHALL proposer aux managers connectés une entrée « Mes modèles » dans la navigation principale, signalée comme page courante sur tous les écrans de gestion des modèles de questions (liste, création, détail, modification).

#### Scenario: Liste des modèles
- **WHEN** un manager connecté ouvre la liste de ses modèles
- **THEN** l'entrée « Mes modèles » est signalée comme page courante et aucune autre entrée ne l'est

#### Scenario: Création ou modification d'un modèle
- **WHEN** un manager connecté ouvre la création ou la modification d'un modèle, y compris après un enregistrement refusé
- **THEN** l'entrée « Mes modèles » est signalée comme page courante

#### Scenario: Visiteur non connecté
- **WHEN** un visiteur non connecté consulte la navigation
- **THEN** l'entrée « Mes modèles » ne lui est pas proposée
