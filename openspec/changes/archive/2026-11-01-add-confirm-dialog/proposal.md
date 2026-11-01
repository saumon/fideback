# Proposal

## Why

Huit actions demandent aujourd'hui une confirmation par l'alerte native du navigateur (`data-turbo-confirm`) : lancer, clôturer ou supprimer une campagne, renvoyer une invitation, soumettre ses réponses, annuler une invitation, supprimer son compte. Cette alerte porte le style du navigateur, pas celui du site, ses boutons s'appellent « OK » et « Annuler » quel que soit le geste, et elle ne peut pas distinguer une action courante d'une suppression définitive. Le reste de l'interface (toasts, tiroir, pages d'erreur) a déjà un style propre : les confirmations sont la dernière interaction qui en sort.

## What Changes

- Les confirmations des actions du site s'affichent dans une **boîte de dialogue intégrée à la page**, dans le style de Fideback, à la place de l'alerte du navigateur.
- Le bouton de confirmation reprend le libellé du bouton cliqué (« Clôturer la campagne », « Soumettre définitivement »…) et la boîte porte un bouton de retrait « Non, revenir ».
- Une action destructive ou irréversible (suppression de campagne, annulation d'invitation, suppression de compte) prend un **ton danger** : bouton rouge, et le focus démarre sur « Non, revenir ».
- Chaque confirmation peut porter une phrase de détail en plus de son titre, pour dire ce qui va se passer. Les textes existants sont conservés comme titres ; les détails sont ajoutés.
- Le texte « Êtes-vous sûr ? » de la suppression de compte devient « Supprimer votre compte ? », avec un détail sur ce qui sera perdu.
- Sur un écran étroit, la boîte devient une feuille collée en bas, avec des boutons pleine largeur.
- La boîte est accessible : modale, Échap et clic sur le voile la ferment sans confirmer, le focus reste dedans puis revient sur le bouton d'origine, le mouvement réduit coupe l'animation.
- Sans prise en charge de l'élément `<dialog>`, le site retombe sur l'alerte du navigateur : la confirmation n'est jamais perdue.
- Les tests système qui acceptaient l'alerte cliquent désormais le bouton de la boîte.

## Capabilities

### New Capabilities
- `confirm-dialog`: boîte de confirmation intégrée au site pour les actions qui demandent un accord explicite, avec son contenu, son ton, son accessibilité et son comportement sur mobile.

### Modified Capabilities

(aucune : les exigences existantes ne mentionnent pas l'alerte du navigateur)

## Impact

- **Vues** : `campaigns/show`, `respondent_forms/show`, `admin/users/index`, `devise/registrations/edit` (attributs de détail et de ton ajoutés aux déclencheurs) ; les deux layouts reçoivent le partiel de la boîte.
- **JavaScript** : un contrôleur Stimulus `confirm_dialog` qui branche `Turbo.config.forms.confirm`. Aucune dépendance ajoutée à l'importmap.
- **CSS** : section dédiée dans `application.css`, avec les tokens du site.
- **Locales** : `devise.views.fr.yml` (texte de suppression de compte).
- **Tests** : adaptation des 4 tests système qui utilisent `accept_confirm` ; nouveaux tests d'intégration (attributs) et système (clavier, voile, focus, ton danger, mobile).
- **Hors périmètre** : les confirmations pleine page de l'écran *Danger zone* (déjà intégrées au site), et le message de confirmation d'e-mail qui n'est pas une boîte de dialogue.
