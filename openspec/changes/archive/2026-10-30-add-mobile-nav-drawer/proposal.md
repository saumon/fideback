# Proposal

## Why

Sur un écran de téléphone, la navigation principale s'empile sur trois lignes et occupe environ 130 px avant le contenu, pour un Admin comme pour un manager. Le menu grossira encore avec de nouvelles entrées. Un menu adapté au mobile rend la place au contenu et reste facile à atteindre au pouce.

## What Changes

- Sous `40rem` de large, la navigation principale devient un **tiroir latéral** : l'en-tête se réduit au logo et à un bouton menu (trois barres qui se transforment en croix), le tiroir glisse depuis la droite avec un fond assombri, et ses liens arrivent en cascade.
- Le tiroir contient, pour un manager, les entrées principales puis, séparés par un trait, le nom du manager et « Se déconnecter ». Pour un visiteur, il contient « Se connecter » ; **« Créer un compte » reste visible dans l'en-tête**, hors tiroir.
- Le tiroir est accessible : bouton annonçant son état (`aria-expanded`), focus maintenu dans le tiroir, page derrière inerte et défilement bloqué, fermeture par Échap, par clic sur le fond ou par clic sur un lien, retour du focus au bouton.
- L'entrée active garde son gras et sa barre multicolore ; la barre se déroule à l'ouverture du tiroir, puis son dégradé défile en boucle.
- Avec moins de mouvement demandé, le tiroir apparaît sans glissement ni cascade et la barre reste complète et immobile.
- Sans JavaScript, la navigation reste un bloc de liens empilés, entièrement utilisable.
- Au-delà de `40rem`, la navigation horizontale actuelle est inchangée.

Hors périmètre : nouvelles entrées de menu, barre d'onglets en bas d'écran, refonte de l'en-tête de l'espace d'un sondé (il n'a pas de navigation).

## Capabilities

### New Capabilities

(aucune)

### Modified Capabilities
- `main-navigation`: ajout de l'exigence de menu mobile en tiroir et de son accessibilité ; le surlignage animé et le mouvement réduit sont précisés pour le tiroir.

## Impact

- Code : `app/views/layouts/application.html.erb` (bouton menu, conteneur du tiroir), nouveau contrôleur Stimulus `app/javascript/controllers/nav_drawer_controller.js`, `app/assets/stylesheets/application.css` (en-tête et tiroir en petit écran, animations).
- Pas de migration ni de nouvelle dépendance (Stimulus et importmap sont déjà là).
- Tests : tests d'intégration sur le balisage du menu (bouton, attributs ARIA, contenu pour chaque profil) et test système (Chrome headless) sur l'ouverture, la fermeture, Échap, le focus et le défilement.
