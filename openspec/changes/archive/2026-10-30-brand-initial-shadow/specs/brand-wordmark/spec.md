# Spec Delta

## Purpose

Fait du logotype « Fideback » de la barre du haut un écho visible de l'icône de l'application, pour que la page et l'onglet portent la même marque, sur tous les espaces du site.

## ADDED Requirements

### Requirement: Initiale assortie à l'icône
Le système SHALL afficher le « F » initial du logotype « Fideback » de la barre du haut en couleur encre, avec une ombre rose pleine, sans flou, décalée vers le bas à droite et proportionnée à la taille du texte, comme sur l'icône de l'application. Les autres lettres du mot MUST garder leur style actuel, sans ombre.

#### Scenario: Barre du haut de l'espace des managers
- **WHEN** un visiteur ouvre une page de l'espace des managers
- **THEN** le « F » du logotype est encre, avec une ombre rose nette décalée vers le bas à droite, et « ideback » s'affiche sans ombre

#### Scenario: Barre du haut de l'espace des sondés
- **WHEN** un sondé ouvre son lien personnel de réponse
- **THEN** le « F » du logotype a le même style encre et rose que dans l'espace des managers

### Requirement: Nom du logotype intact
Le système SHALL conserver « Fideback » d'un seul tenant comme texte du logotype. Le style de l'initiale MUST ne pas couper le mot pour les technologies d'assistance ni pour la recherche dans la page.

#### Scenario: Lecteur d'écran
- **WHEN** un lecteur d'écran annonce le lien du logotype dans l'espace des managers
- **THEN** il lit « Fideback » en un seul mot, et non « F » puis « ideback »

#### Scenario: Recherche dans la page
- **WHEN** un visiteur cherche « Fideback » dans la page avec la recherche du navigateur
- **THEN** le logotype fait partie des résultats
