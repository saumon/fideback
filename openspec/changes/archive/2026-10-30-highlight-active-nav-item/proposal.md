# Proposal

## Why

La navigation principale n'indique pas dans quel écran on se trouve : tous les liens ont le même aspect, quelle que soit la page ouverte. Surligner l'entrée de la section courante aide à se repérer, et donne un état accessible (`aria-current`) aux lecteurs d'écran.

## What Changes

- L'entrée du menu qui correspond à l'écran ouvert est surlignée : texte en gras et barre épaisse multicolore (rose, safran, jade, azur) qui se déroule sous le lien.
- La correspondance se fait par section, pas par adresse exacte : tous les écrans d'une campagne (liste, création, détail, édition, synthèses) surlignent « Mes campagnes » ; « Administration » reste surlignée sur l'écran des utilisateurs.
- Le lien actif porte `aria-current="page"`, y compris pour les technologies d'assistance.
- Aucune entrée n'est surlignée sur les pages qui n'ont pas d'entrée de menu (accueil, page introuvable, espace sondé).
- L'animation respecte `prefers-reduced-motion`, et le menu ne se décale pas d'un écran à l'autre. L'espacement entre lignes du menu est augmenté pour que la barre ne touche pas la ligne suivante quand le menu passe à la ligne sur mobile.

Hors périmètre : refonte de la navigation, ajout ou réordonnancement d'entrées, menu mobile dédié.

## Capabilities

### New Capabilities
- `main-navigation`: indication, dans la navigation principale, de l'entrée correspondant à l'écran ouvert.

### Modified Capabilities

(aucune : le lien « Administration » garde ses règles de visibilité dans `admin-area`)

## Impact

- Code : `app/views/layouts/application.html.erb` (liens de la navigation), `app/helpers/application_helper.rb` (calcul de la section courante), `app/assets/stylesheets/application.css` (style du lien actif).
- Pas de migration ni de nouvelle dépendance.
- Tests : intégration sur `aria-current` pour chaque section, pour un visiteur et pour un manager ; les tests existants sur les liens du menu doivent rester valables.
