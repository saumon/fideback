# Spec Delta

## ADDED Requirements

### Requirement: Marque à deux bulles de dialogue
Le système SHALL afficher, devant le logotype « Fideback » de la barre du haut, une marque de deux bulles de dialogue : une bulle rose derrière et à gauche, une bulle devant et à droite, safran au repos, au trait encre, avec trois points dans la bulle de devant. Les six pastilles colorées MUST ne plus être affichées.

#### Scenario: Espace des managers
- **WHEN** un visiteur ouvre une page de l'espace des managers
- **THEN** la barre du haut montre une bulle rose derrière une bulle de devant, devant le logotype, et aucune des six pastilles

#### Scenario: Espace des sondés
- **WHEN** un sondé ouvre son lien personnel de réponse
- **THEN** la barre du haut montre la même marque devant le logotype

### Requirement: Bas de la marque sur la ligne de base
Le système SHALL poser le bas de la marque sur la ligne de base du logotype « Fideback », sans que le dessin descende sous le bas des lettres, au repos et sur tous les écrans. La marque MAY dépasser au-dessus des lettres.

#### Scenario: Écran large
- **WHEN** un visiteur ouvre une page sur un écran large
- **THEN** le bas de la queue de la bulle de devant est au niveau du bas des lettres de « Fideback », à un pixel près, et la marque dépasse au-dessus d'elles

#### Scenario: Écran étroit
- **WHEN** un visiteur ouvre une page sur un écran de 380 px de large
- **THEN** le bas de la marque est toujours au niveau du bas des lettres de « Fideback »

#### Scenario: Hauteur de l'en-tête
- **WHEN** la marque remplace les six pastilles
- **THEN** l'en-tête n'est pas plus haut qu'avant

### Requirement: Marque décorative
Le système SHALL présenter la marque comme un élément décoratif, ignoré des technologies d'assistance, de sorte que le lien du logotype reste annoncé « Fideback » et que son texte reste inchangé.

#### Scenario: Lecteur d'écran
- **WHEN** un lecteur d'écran annonce le lien du logotype
- **THEN** il lit « Fideback » seulement, sans description des bulles

### Requirement: Arrivée animée de la marque
Le système SHALL animer l'arrivée de la marque quand la page est chargée : la bulle rose apparaît en rebondissant, puis la bulle de devant. Cette arrivée MUST ne pas se rejouer quand le visiteur navigue vers une autre page du site sans rechargement complet.

#### Scenario: Chargement d'une page
- **WHEN** un visiteur charge une page du site
- **THEN** la bulle rose apparaît en rebondissant, puis la bulle de devant, et la marque prend sa forme complète

#### Scenario: Navigation d'une page à l'autre
- **WHEN** un manager connecté clique sur « Mon équipe » depuis « Mes campagnes »
- **THEN** la marque reste en place sans rejouer son arrivée

### Requirement: Bulle de devant aux couleurs des voix
Le système SHALL faire passer la bulle de devant, en boucle et sans limite de durée, par le safran, le jade, l'azur, l'orchidée et le citron vert, en revenant au safran, avec un passage rapide d'une couleur à la suivante. La bulle de derrière MUST rester rose, et les trois points MUST rester lisibles sur chaque couleur.

#### Scenario: Défilé des couleurs
- **WHEN** la marque a fini son arrivée et que la page reste affichée
- **THEN** la bulle de devant change de couleur à tour de rôle, dans l'ordre safran, jade, azur, orchidée, citron vert, puis revient au safran

#### Scenario: Bulle de derrière
- **WHEN** la bulle de devant change de couleur
- **THEN** la bulle de derrière reste rose

#### Scenario: Lisibilité des points
- **WHEN** la bulle de devant prend chacune des cinq couleurs
- **THEN** les trois points encre ont avec elle un contraste d'au moins 3:1

#### Scenario: Pendant le survol
- **WHEN** le pointeur passe sur le logo
- **THEN** la bulle de devant poursuit son défilé de couleurs pendant que les bulles se balancent

### Requirement: Points de saisie en mouvement continu
Le système SHALL faire pulser à tour de rôle, en boucle et sans limite de durée, les trois points de la bulle de devant, tant que la page est affichée, comme une saisie en cours. La pulsation MUST ne pas être interrompue par le survol du logo.

#### Scenario: Après l'arrivée
- **WHEN** la marque a fini son arrivée
- **THEN** les trois points pulsent à tour de rôle, l'un après l'autre

#### Scenario: Page laissée ouverte
- **WHEN** une page reste ouverte pendant plusieurs minutes
- **THEN** les trois points continuent de pulser à tour de rôle

#### Scenario: Pendant le survol
- **WHEN** le pointeur passe sur le logo alors que les points pulsent
- **THEN** les points continuent de pulser pendant que les bulles se balancent

### Requirement: Réaction au survol
Le système SHALL balancer les deux bulles, l'une après l'autre, quand le pointeur survole le logo ou que le lien du logotype reçoit le focus au clavier. Le mouvement MUST s'arrêter de lui-même et rendre la marque à son état de repos.

#### Scenario: Survol à la souris
- **WHEN** le pointeur passe sur le logo
- **THEN** les deux bulles se balancent, puis reviennent à leur place

#### Scenario: Focus au clavier
- **WHEN** un visiteur place le focus clavier sur le lien du logotype
- **THEN** les bulles se balancent comme au survol

### Requirement: Mouvement réduit
Le système SHALL n'animer aucun élément de la marque quand le visiteur demande une réduction des animations : elle s'affiche immobile, dans son état final, avec les deux bulles et les trois points visibles, la bulle de devant restant safran, sans pulsation ni changement de couleur.

#### Scenario: Réduction demandée
- **WHEN** le système d'un visiteur demande un mouvement réduit et qu'il charge une page
- **THEN** les deux bulles et les trois points sont affichés immobiles, sans apparition ni pulsation, et le survol ne les anime pas

### Requirement: Marque sur écran étroit
Le système SHALL garder la marque visible à côté du logotype sur un écran étroit, y compris sur les plus petits, où elle rétrécit au lieu de disparaître. L'en-tête MUST rester sur une seule ligne avec le bouton de menu et, pour un visiteur, le bouton « Créer un compte ».

#### Scenario: Téléphone courant
- **WHEN** un visiteur ouvre le site sur un écran de 380 px de large
- **THEN** la marque est affichée à côté du nom, et le logo, « Créer un compte » et le bouton de menu tiennent sur une ligne

#### Scenario: Très petit écran
- **WHEN** un visiteur ouvre le site sur un écran de 360 px de large
- **THEN** la marque, plus petite, reste affichée et l'en-tête tient toujours sur une ligne
