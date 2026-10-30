# app-icon Specification

## Purpose

Donne à Fideback une icône reconnaissable, fidèle à son identité visuelle, dans les onglets, les favoris et les écrans d'accueil, sur toutes ses pages et quel que soit le thème du système.

## Requirements

### Requirement: Icône de marque
Le système SHALL présenter comme icône d'application un « F » couleur encre, condensé et gras, accompagné d'une ombre rose pleine décalée vers le bas à droite, sur fond transparent. L'icône générique de Rails MUST ne plus être servie.

#### Scenario: Onglet en thème clair
- **WHEN** un visiteur ouvre une page de Fideback dans un navigateur en thème clair
- **THEN** l'onglet affiche le F encre avec son ombre rose

#### Scenario: Ancienne icône
- **WHEN** un navigateur demande l'icône de l'application
- **THEN** il reçoit l'icône Fideback et non le rond rouge de Rails

### Requirement: Lisibilité en thème sombre
Le système SHALL afficher le F dans une couleur claire lorsque le système de l'utilisateur est en thème sombre, sur les navigateurs qui prennent en charge les icônes vectorielles. L'ombre rose MUST rester identique dans les deux thèmes.

#### Scenario: Onglet en thème sombre
- **WHEN** un visiteur ouvre une page de Fideback avec un système en thème sombre, dans un navigateur qui affiche l'icône vectorielle
- **THEN** l'onglet affiche le F en clair avec son ombre rose, nettement visible sur le fond sombre

### Requirement: Icône sur toutes les pages
Le système SHALL déclarer l'icône sur toutes les pages qu'il sert : l'espace des managers, l'espace des sondés et les pages d'erreur. L'adresse `/favicon.ico` MUST renvoyer l'icône.

#### Scenario: Espace des sondés
- **WHEN** un sondé ouvre son lien personnel de réponse
- **THEN** l'onglet affiche l'icône Fideback

#### Scenario: Page d'erreur
- **WHEN** un visiteur arrive sur une page introuvable
- **THEN** l'onglet affiche l'icône Fideback

#### Scenario: Requête implicite
- **WHEN** un client demande `/favicon.ico`
- **THEN** il reçoit l'icône, et non une erreur 404

### Requirement: Icône d'écran d'accueil
Le système SHALL fournir une icône d'écran d'accueil sans transparence, sur laquelle le F encre et son ombre rose sont posés sur le fond clair de l'application, pour que la plateforme ne la remplisse pas de noir.

#### Scenario: Ajout à l'écran d'accueil sur iOS
- **WHEN** un utilisateur ajoute Fideback à l'écran d'accueil d'un iPhone
- **THEN** l'icône montre le F encre et son ombre rose sur un fond clair
