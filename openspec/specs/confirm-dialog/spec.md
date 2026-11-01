# confirm-dialog Specification

## Purpose

Demande un accord explicite avant une action engageante (lancement, clôture, suppression, renvoi, soumission) par une boîte de dialogue intégrée au site, dans son style, accessible au clavier et aux technologies d'assistance, sur desktop comme sur mobile.

## Requirements

### Requirement: Boîte intégrée au site
Le système SHALL demander la confirmation d'une action dans une boîte de dialogue modale affichée par-dessus la page, dans le style du site, et MUST NOT utiliser l'alerte native du navigateur. Tant que la boîte est ouverte, le reste de la page ne réagit pas aux clics ni au clavier.

#### Scenario: Clôture d'une campagne
- **WHEN** un manager clique sur « Clôturer la campagne »
- **THEN** une boîte au style du site s'ouvre par-dessus la page avec la question « Clôturer la campagne ? », et aucune alerte du navigateur n'apparaît

#### Scenario: Page figée derrière la boîte
- **WHEN** la boîte est ouverte et que l'utilisateur clique sur un lien de la page en dessous
- **THEN** le clic est sans effet et la boîte reste ouverte

#### Scenario: Espace des sondés
- **WHEN** un sondé clique sur « Soumettre définitivement »
- **THEN** la même boîte s'ouvre dans l'espace des sondés, avec le même style que dans l'espace des managers

### Requirement: Actions concernées
Le système SHALL passer par cette boîte pour toutes les actions qui demandent une confirmation : lancement, clôture et suppression d'une campagne, renvoi d'une invitation à un sondé ou à un manager invité, annulation d'une invitation, soumission définitive des réponses et suppression du compte.

#### Scenario: Renvoi à un sondé
- **WHEN** un manager clique sur « Renvoyer » à côté d'un sondé
- **THEN** la boîte demande « Renvoyer l'invitation à » suivi du nom du sondé

#### Scenario: Annulation d'une invitation de manager
- **WHEN** l'Admin clique sur « Annuler » à côté d'une invitation en attente
- **THEN** la boîte demande « Annuler l'invitation de » suivi du nom de l'invité

### Requirement: Contenu de la boîte
La boîte SHALL afficher un titre qui formule la question et, quand l'action le justifie, une phrase de détail qui dit ce qui va se passer. Elle SHALL proposer deux boutons : « Non, revenir », et un bouton de confirmation dont le libellé est celui du bouton cliqué.

#### Scenario: Libellé de confirmation
- **WHEN** la boîte s'ouvre après un clic sur « Soumettre définitivement »
- **THEN** son bouton de confirmation s'intitule « Soumettre définitivement » et non « OK »

#### Scenario: Détail de la soumission
- **WHEN** la boîte de soumission s'ouvre
- **THEN** elle précise qu'après soumission les réponses ne peuvent plus être modifiées

#### Scenario: Suppression du compte
- **WHEN** un manager clique sur « Supprimer mon compte »
- **THEN** la boîte demande « Supprimer votre compte ? » et précise que ses campagnes, ses contacts et les réponses recueillies seront supprimés

### Requirement: Issue de la confirmation
Le système SHALL n'exécuter l'action que si l'utilisateur utilise le bouton de confirmation. Le bouton « Non, revenir », la touche Échap et un clic sur le voile autour de la boîte MUST fermer la boîte sans exécuter l'action et sans modifier la page.

#### Scenario: Confirmation
- **WHEN** un manager clique sur « Clôturer la campagne » puis sur le bouton de confirmation de la boîte
- **THEN** la boîte se ferme et la campagne est clôturée

#### Scenario: Retrait par le bouton
- **WHEN** un manager ouvre la boîte de clôture puis clique sur « Non, revenir »
- **THEN** la boîte se ferme et la campagne reste en cours

#### Scenario: Retrait par Échap
- **WHEN** la boîte est ouverte et que l'utilisateur appuie sur Échap
- **THEN** la boîte se ferme et l'action n'est pas exécutée

#### Scenario: Retrait par le voile
- **WHEN** la boîte est ouverte et que l'utilisateur clique sur le voile en dehors d'elle
- **THEN** la boîte se ferme et l'action n'est pas exécutée

### Requirement: Ton danger
Le système SHALL présenter en ton danger les actions destructives ou irréversibles : suppression d'une campagne, annulation d'une invitation et suppression du compte. Le bouton de confirmation est alors rouge, et le focus clavier démarre sur « Non, revenir ». Les autres actions gardent le ton neutre, avec le focus sur le bouton de confirmation.

#### Scenario: Suppression d'une campagne
- **WHEN** un manager clique sur « Supprimer » sur la page d'une campagne
- **THEN** le bouton de confirmation de la boîte est rouge et « Non, revenir » a le focus

#### Scenario: Action courante
- **WHEN** un manager clique sur « Lancer la campagne »
- **THEN** le bouton de confirmation n'est pas rouge et il a le focus

### Requirement: Accessibilité au clavier et aux lecteurs d'écran
La boîte SHALL être annoncée comme une boîte de dialogue modale, nommée par son titre et décrite par son détail. Le focus MUST rester dans la boîte tant qu'elle est ouverte, et revenir sur le bouton qui l'a ouverte à sa fermeture.

#### Scenario: Navigation au clavier
- **WHEN** la boîte est ouverte et que l'utilisateur appuie plusieurs fois sur Tab
- **THEN** le focus circule entre les deux boutons de la boîte et ne passe jamais sur la page en dessous

#### Scenario: Retour du focus
- **WHEN** l'utilisateur ferme la boîte sans confirmer
- **THEN** le focus est de nouveau sur le bouton qu'il avait activé

#### Scenario: Annonce
- **WHEN** la boîte s'ouvre
- **THEN** une technologie d'assistance annonce une boîte de dialogue modale dont le nom est le titre de la boîte

### Requirement: Affichage sur mobile
Le système SHALL afficher la boîte comme une feuille collée au bas de l'écran sur un écran étroit, sur toute la largeur, avec des boutons pleine largeur, le bouton de confirmation au-dessus de « Non, revenir ». Sur un écran large, elle SHALL être centrée avec une largeur limitée. Elle MUST rester dans la zone visible et hors des zones réservées par l'appareil.

#### Scenario: Téléphone
- **WHEN** la boîte s'ouvre sur un écran de 380 px de large
- **THEN** elle occupe toute la largeur en bas de l'écran, ses boutons sont empilés et aucun défilement horizontal n'apparaît

#### Scenario: Desktop
- **WHEN** la boîte s'ouvre sur un écran large
- **THEN** elle est centrée, avec une largeur limitée, et les deux boutons sont côte à côte

### Requirement: Mouvement réduit
Le système SHALL limiter l'ouverture et la fermeture de la boîte à un affichage sans mouvement quand l'utilisateur demande une réduction des animations.

#### Scenario: Réduction demandée
- **WHEN** le système de l'utilisateur demande un mouvement réduit et que la boîte s'ouvre
- **THEN** elle apparaît sans glissement ni rebond

### Requirement: Repli sans boîte intégrée
Le système SHALL conserver la confirmation même si le navigateur ne sait pas afficher la boîte intégrée, en retombant sur l'alerte native. Une action qui demande confirmation MUST NOT s'exécuter sans que l'utilisateur ait confirmé.

#### Scenario: Navigateur sans prise en charge
- **WHEN** le navigateur ne sait pas afficher la boîte et que l'utilisateur clique sur « Supprimer » sur la page d'une campagne
- **THEN** l'alerte native demande la confirmation et la campagne n'est supprimée qu'après un accord
