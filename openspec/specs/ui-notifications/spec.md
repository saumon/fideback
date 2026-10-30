# ui-notifications Specification

## Purpose

Informe l'utilisateur du résultat d'une action (connexion, déconnexion, création, lancement, clôture, renvoi, enregistrement, erreur) par des messages éphémères posés au premier plan, sans déplacer le contenu de la page, sur desktop comme sur mobile.

## Requirements

### Requirement: Affichage au premier plan
Le système SHALL afficher chaque message consécutif à une action sous forme de toast superposé au contenu, au-dessus de tout autre élément de la page. L'apparition, la disparition ou la fermeture d'un toast MUST ne déplacer aucun élément de l'interface.

#### Scenario: Message après une redirection
- **WHEN** un manager clôture une campagne et revient sur la page de la campagne
- **THEN** « Campagne clôturée. » s'affiche en toast par-dessus la page, et le titre de la campagne occupe la même position qu'en l'absence de message

#### Scenario: Message sur une page réaffichée
- **WHEN** un sondé soumet un formulaire auquel il manque des notes
- **THEN** le message de rappel s'affiche en toast par-dessus la page, sans décaler le formulaire

#### Scenario: Espace des sondés
- **WHEN** un message est affiché sur une page de l'espace des sondés
- **THEN** il s'affiche en toast de la même façon que dans l'espace des managers

### Requirement: Placement selon la taille d'écran
Le système SHALL placer les toasts en bas à droite de la fenêtre sur un écran large, et en bas au centre sur un écran étroit, sur toute la largeur moins une marge de chaque côté. Les toasts MUST rester dans la zone visible et hors des zones réservées par l'appareil (encoche, barre de geste).

#### Scenario: Desktop
- **WHEN** un toast s'affiche dans une fenêtre large
- **THEN** il apparaît en bas à droite, sans recouvrir l'en-tête ni la navigation

#### Scenario: Mobile
- **WHEN** un toast s'affiche sur un téléphone
- **THEN** il apparaît en bas, sur toute la largeur moins une marge de chaque côté, au-dessus de la barre de geste, sans provoquer de défilement horizontal

### Requirement: Durée de vie des notices
Le système SHALL faire disparaître automatiquement un toast de notice après un délai de quelques secondes, allongé selon la longueur du texte, et SHALL indiquer visuellement le temps restant.

#### Scenario: Disparition automatique
- **WHEN** un toast « Connecté(e). » s'affiche et que l'utilisateur n'interagit pas avec lui
- **THEN** il disparaît de lui-même après le délai

#### Scenario: Texte plus long
- **WHEN** une notice contient un texte plus long, comme « Campagne lancée : les invitations sont envoyées. »
- **THEN** elle reste affichée plus longtemps qu'une notice courte

### Requirement: Suspension du minuteur
Le système SHALL suspendre le décompte d'une notice tant que le pointeur la survole, que le focus clavier est dans le toast ou que l'onglet n'est pas visible, et SHALL le reprendre ensuite sans le remettre à zéro.

#### Scenario: Survol
- **WHEN** l'utilisateur garde le pointeur sur une notice au-delà de son délai
- **THEN** elle reste affichée, puis disparaît après le temps qui lui restait une fois le pointeur retiré

#### Scenario: Onglet en arrière-plan
- **WHEN** l'utilisateur change d'onglet juste après l'apparition d'une notice, puis revient
- **THEN** la notice est toujours affichée à son retour

### Requirement: Persistance des alertes
Le système SHALL laisser un toast d'alerte affiché jusqu'à ce que l'utilisateur le ferme ou quitte la page. Une alerte MUST ne jamais disparaître d'elle-même.

#### Scenario: Alerte d'un refus
- **WHEN** le renvoi d'une invitation est refusé et que le message d'alerte s'affiche
- **THEN** le toast reste affiché, sans indicateur de temps restant, jusqu'à sa fermeture par l'utilisateur

#### Scenario: Rappel de notes manquantes
- **WHEN** le toast « Il manque des notes… » s'affiche
- **THEN** il reste affiché jusqu'à sa fermeture, et les champs concernés restent signalés dans le formulaire

### Requirement: Fermeture par l'utilisateur
Le système SHALL permettre de fermer tout toast par un bouton de fermeture accessible au clavier et doté d'un nom accessible, et, sur écran tactile, par un balayage horizontal.

#### Scenario: Bouton de fermeture
- **WHEN** l'utilisateur active le bouton de fermeture d'un toast, à la souris ou au clavier
- **THEN** le toast disparaît

#### Scenario: Balayage
- **WHEN** l'utilisateur balaie un toast horizontalement au-delà d'un seuil
- **THEN** le toast disparaît ; en deçà du seuil, il revient à sa place

### Requirement: Empilement limité
Le système SHALL empiler les toasts simultanés sans qu'ils se recouvrent et SHALL en limiter le nombre visible. Quand la limite est dépassée, la notice la plus ancienne MUST être retirée en premier ; une alerte MUST ne jamais être retirée pour faire de la place.

#### Scenario: Plusieurs messages
- **WHEN** une page reçoit une notice et une alerte
- **THEN** les deux toasts sont visibles, empilés l'un au-dessus de l'autre

#### Scenario: Dépassement de la limite
- **WHEN** le nombre de toasts dépasse la limite et que la pile contient une alerte et des notices
- **THEN** la notice la plus ancienne est retirée et l'alerte reste affichée

### Requirement: Annonce aux technologies d'assistance
Le système SHALL faire annoncer chaque toast par les lecteurs d'écran, poliment pour une notice et immédiatement pour une alerte, y compris pour un message présent dès le chargement de la page. L'apparition d'un toast MUST ne pas déplacer le focus.

#### Scenario: Notice annoncée
- **WHEN** une page s'affiche avec la notice « Connecté(e). »
- **THEN** un lecteur d'écran annonce le message sans interrompre la lecture en cours, et le focus reste où il était

#### Scenario: Alerte annoncée
- **WHEN** une page s'affiche avec un message d'alerte
- **THEN** un lecteur d'écran annonce le message immédiatement

### Requirement: Mouvement réduit
Le système SHALL afficher et retirer les toasts sans déplacement animé lorsque l'utilisateur a demandé à réduire les animations.

#### Scenario: Préférence de mouvement réduit
- **WHEN** l'utilisateur a activé la réduction des animations dans son système
- **THEN** les toasts apparaissent et disparaissent sans glissement ni rebond

### Requirement: Pas de réapparition à la navigation
Le système SHALL ne présenter un message qu'une fois. Un toast MUST ne pas réapparaître lorsque l'utilisateur revient sur une page par l'historique du navigateur, et MUST disparaître lorsque l'utilisateur quitte la page.

#### Scenario: Retour arrière
- **WHEN** un manager voit « Campagne clôturée. », navigue vers une autre page puis revient en arrière
- **THEN** le toast ne réapparaît pas

#### Scenario: Alerte non fermée
- **WHEN** l'utilisateur quitte une page alors qu'une alerte y est encore affichée
- **THEN** l'alerte n'apparaît pas sur la page suivante

### Requirement: Messages d'état dans la page
Le système SHALL afficher dans le contenu de la page, et non en toast, les messages qui décrivent l'état durable de ce qui est affiché : réponses déjà soumises, campagne terminée, erreurs de validation d'un formulaire de campagne, issue d'une confirmation de compte. Ces messages MUST rester visibles tant que l'état dure.

#### Scenario: Campagne terminée
- **WHEN** un sondé ouvre le lien d'une campagne qui n'accepte plus de réponses
- **THEN** le message indiquant que la campagne est terminée s'affiche dans la page et ne disparaît pas

#### Scenario: Erreurs d'un formulaire de campagne
- **WHEN** un manager enregistre une campagne invalide
- **THEN** la liste des erreurs s'affiche dans le formulaire et y reste

### Requirement: Fonctionnement sans JavaScript
Le système SHALL rendre les messages lisibles même lorsque JavaScript ne s'exécute pas : ils restent affichés au premier plan et peuvent être lus, sans disparition automatique.

#### Scenario: JavaScript indisponible
- **WHEN** une page avec une notice s'affiche dans un navigateur où JavaScript est désactivé
- **THEN** le message est visible et lisible
