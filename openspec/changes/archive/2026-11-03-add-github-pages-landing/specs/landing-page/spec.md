# Spec Delta

## Purpose

Donne au projet une vitrine statique publiée avec GitHub Pages, reprenant le style de l'accueil de l'application, qui présente Fideback et sert de support aux campagnes marketing en menant vers le dépôt GitHub.

## ADDED Requirements

### Requirement: Page statique publiable avec GitHub Pages
Le système SHALL fournir la landing page sous forme de fichiers statiques dans le dossier `docs/`, servie telle quelle à `https://saumon.github.io/fideback/`, sans serveur applicatif. La page MUST fonctionner sans JavaScript et ne charger aucune ressource d'un domaine externe, y compris sa police.

#### Scenario: Ouverture depuis GitHub Pages
- **WHEN** un visiteur ouvre `https://saumon.github.io/fideback/`
- **THEN** la page s'affiche entièrement, avec sa police et son icône, sans aucune requête vers un autre domaine

#### Scenario: Ouverture depuis un autre chemin
- **WHEN** les fichiers de `docs/` sont servis depuis un autre préfixe d'URL ou ouverts depuis le disque
- **THEN** la feuille de style, la police et l'icône se chargent encore, car tous les liens sont relatifs

### Requirement: Style et animations de l'accueil
La landing SHALL reprendre le style de l'accueil déconnecté de l'application : police Bricolage Grotesque, couleurs saturées, logo à deux bulles de dialogue animé, titre dont chaque mot arrive avec son rebond et sa couleur, et scène de synthèse d'exemple. Les animations MUST s'arrêter ou devenir fixes quand le visiteur demande un mouvement réduit.

#### Scenario: Chargement de la page
- **WHEN** un visiteur charge la page
- **THEN** le logo arrive en rebondissant, le titre s'écrit mot par mot en couleurs, et la scène de synthèse s'anime

#### Scenario: Mouvement réduit
- **WHEN** un visiteur dont le système demande un mouvement réduit charge la page
- **THEN** le logo, le titre et la scène s'affichent immobiles et lisibles

### Requirement: Bouton GitHub à la place des boutons de compte
La landing SHALL ne proposer ni « Se connecter » ni « Créer un compte ». Elle SHALL proposer un bouton « Voir sur GitHub », orné du logo GitHub, qui mène à `https://github.com/saumon/fideback`, dans l'en-tête et dans la première section, et répété à la fin de la page. Le logo MUST être inclus dans la page, être décoratif pour les lecteurs d'écran, et le bouton MUST rester nommé par son texte.

#### Scenario: Appel à l'action
- **WHEN** un visiteur clique sur le bouton « Voir sur GitHub », où qu'il soit sur la page
- **THEN** il arrive sur le dépôt `https://github.com/saumon/fideback`

#### Scenario: Aucun lien de compte
- **WHEN** un visiteur parcourt la page
- **THEN** aucun lien ni bouton ne mène à une connexion ou à une création de compte

#### Scenario: Lecteur d'écran
- **WHEN** un lecteur d'écran annonce le bouton
- **THEN** il lit « Voir sur GitHub », sans annoncer le dessin du logo

### Requirement: Présentation du projet
La landing SHALL présenter Fideback en français, dans cet ordre : une promesse d'accueil avec la scène de synthèse d'exemple, les trois étapes (créer une campagne, les sondés répondent, lire la synthèse), le problème que le projet résout, ses fonctionnalités principales, la transparence des réponses nominatives, et le fait que le projet est libre et auto-hébergeable.

#### Scenario: Parcours de la page
- **WHEN** un visiteur fait défiler la page du haut vers le bas
- **THEN** il rencontre successivement la promesse, la scène d'exemple, les trois étapes, le problème, les fonctionnalités, la transparence des réponses nominatives, la mention open source et auto-hébergeable, puis le bouton GitHub final

#### Scenario: Réponses nominatives
- **WHEN** un visiteur lit la section de transparence
- **THEN** elle indique que les réponses des sondés sont nominatives et que les sondés en sont informés

### Requirement: Adaptation à tous les écrans
La landing SHALL rester lisible et utilisable du téléphone au grand écran, sans défilement horizontal, et ses textes MUST rester lisibles sur leur fond en contraste.

#### Scenario: Téléphone
- **WHEN** un visiteur ouvre la page sur un écran de 360 px de large
- **THEN** aucune partie du contenu ne déborde horizontalement et le bouton GitHub reste visible dans l'en-tête et le contenu

### Requirement: Partage et référencement
La landing SHALL déclarer, en français, un titre, une description, une URL canonique `https://saumon.github.io/fideback/`, des métadonnées Open Graph et Twitter Card avec une image de prévisualisation servie par la page, ainsi que l'icône du site.

#### Scenario: Aperçu d'un lien partagé
- **WHEN** l'adresse de la page est partagée dans un réseau social ou une messagerie
- **THEN** l'aperçu affiche le titre, la description et l'image de prévisualisation de Fideback

### Requirement: Fichiers servis tels quels
Le dossier `docs/` SHALL contenir un fichier `.nojekyll` pour que GitHub Pages serve les fichiers sans transformation.

#### Scenario: Fichiers statiques
- **WHEN** GitHub Pages publie le dossier `docs/`
- **THEN** `landing.css`, la police, l'icône et l'image de prévisualisation sont servis tels quels
