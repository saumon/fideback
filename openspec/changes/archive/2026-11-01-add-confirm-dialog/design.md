# Design

## Context

- Huit déclencheurs portent `data-turbo-confirm` : sur le `<form>` généré par `button_to` (`form: { data: { turbo_confirm: … } }`) dans `campaigns/show`, `admin/users/index`, ou sur le bouton lui-même (`respondent_forms/show`, `devise/registrations/edit`). Turbo 2.0.23 (Turbo 8) lit l'attribut sur le bouton déclencheur puis sur le formulaire, et appelle `Turbo.config.forms.confirm(message, formElement, submitter)`, qui peut renvoyer une promesse de booléen. Sans réglage, il appelle `window.confirm`.
- La vue de compte pose aussi `data-confirm` (reliquat de rails-ujs, sans effet avec Turbo) ; on le laisse de côté.
- Les deux layouts (`application`, `respondent`) rendent déjà le partiel `layouts/_toasts`, dont le contrôleur place la colonne de toasts dans la couche supérieure (popover). Le tiroir mobile code à la main son piège à focus et son inertie.
- Le style repose sur des tokens (`--ink`, `--pink`, `--saffron`, `--danger`, `--surface`, `--bounce`, `--glide`), des bordures de 2px et des ombres décalées pleines. Les classes `.btn`, `.btn-primary`, `.btn-danger` et `.btn-solid-danger` existent. Le site est en thème clair uniquement.
- Les tests système utilisent `accept_confirm` à quatre endroits (`feedback_journey_test`, `toasts_test`). Un `accept_confirm` n'intercepte pas une boîte maison : ils doivent changer.

## Goals / Non-Goals

**Goals:**
- Aucune vue ne change de forme : les `data-turbo-confirm` restent le point d'entrée. Une action sans attribut supplémentaire obtient une boîte correcte (titre, bouton de confirmation nommé d'après le bouton cliqué, ton neutre).
- Aucune dépendance ajoutée : un contrôleur Stimulus, un partiel, du CSS.
- Le comportement modal vient de la plateforme, pas d'un code maison.

**Non-Goals:**
- Pas d'API JavaScript publique pour ouvrir une boîte hors d'un formulaire Turbo.
- Pas de remplacement des pages de confirmation de l'écran *Danger zone*.
- Pas de thème sombre : le site n'en a pas.

## Decisions

### 1. Brancher la boîte sur la confirmation de Turbo

Un contrôleur Stimulus `confirm-dialog`, posé sur la boîte, affecte `Turbo.config.forms.confirm` à sa connexion et le retire à sa déconnexion (seulement si la valeur est toujours la sienne). La fonction renvoie une promesse : `true` si l'utilisateur confirme, `false` sinon. Turbo décide ensuite d'envoyer ou non le formulaire ; aucune soumission n'est rejouée à la main.

*Écarté :* intercepter `submit` ou `click` soi-même. Cela duplique ce que Turbo fait déjà, notamment pour `button_to` avec `method: :delete` et pour `formaction` du bouton de soumission des sondés.

### 2. L'élément `<dialog>` natif, ouvert avec `showModal()`

La boîte est un `<dialog>` : couche supérieure du navigateur (aucun `z-index`), reste de la page inerte, piège à focus, Échap et retour du focus sur l'élément d'origine fournis par la plateforme. Le nom accessible vient de `aria-labelledby` (titre), la description de `aria-describedby` (détail). Le clic sur le voile est géré en testant `event.target === dialog`, le contenu étant dans un `<form method="dialog">` interne dont le corps recouvre toute la surface de la boîte.

Le focus initial est posé par `autofocus` déplacé à chaque ouverture : « Non, revenir » en ton danger, le bouton de confirmation sinon.

*Écarté :* un `div role="dialog"` avec piège à focus maison, comme le tiroir. Plus de code, plus de cas limites (lecteurs d'écran, Tab arrière), pour moins de garanties.

### 3. Contenu lu sur le déclencheur, tout en `data-*` facultatifs

Le message de `data-turbo-confirm` devient le titre. Trois attributs facultatifs, lus sur le bouton déclencheur puis sur le formulaire (même ordre que Turbo) :

| Attribut | Rôle | Défaut |
|---|---|---|
| `data-turbo-confirm-detail` | phrase sous le titre | aucune (le paragraphe est masqué) |
| `data-turbo-confirm-tone` | `danger` ou `neutral` | `neutral` |
| `data-turbo-confirm-icon` | `send`, `lock`, `check`, `trash`, `warning` | `warning` en ton danger, `check` sinon |

Le libellé du bouton de confirmation est celui du déclencheur : `textContent` d'un `<button>`, `value` d'un `<input type="submit">`. Le texte de retrait, « Non, revenir », est fixe.

*Écarté :* un attribut de libellé par déclencheur. Il se désynchroniserait du bouton visible, et le libellé d'un bouton d'action est déjà le bon verbe.

### 4. Un partiel dans les deux layouts, un seul élément dans la page

`layouts/_confirm_dialog.html.erb` rend le `<dialog>` vide (titre, détail, badge, deux boutons) et est rendu dans les deux layouts, à côté des toasts. Le contenu est rempli à chaque ouverture. Turbo remplace le `<body>` à chaque navigation, donc le contrôleur se reconnecte et le tampon `dialog` est toujours celui de la page courante. Un écouteur `turbo:before-cache` ferme une boîte ouverte, pour que la page mise en cache ne revienne pas avec elle.

*Écarté :* créer le `<dialog>` en JavaScript. Le style et les attributs d'accessibilité sont plus lisibles dans une vue, comme pour les toasts et le tiroir.

### 5. Repli sur `window.confirm`

Si `HTMLDialogElement.prototype.showModal` n'existe pas, la fonction renvoie `window.confirm(message)`. Sans JavaScript ni Turbo, le comportement reste celui d'aujourd'hui (pas de confirmation) : ce n'est pas une régression.

### 6. Style : tokens du site, feuille en bas sur petit écran

Le CSS reprend les tokens et les classes de boutons existants (`.btn-solid-danger` pour la confirmation en danger). L'ombre pleine et la pastille d'icône portent la couleur du ton (`--saffron` ou `--danger`). L'entrée utilise `@starting-style` et des transitions sur `opacity`, `transform`, `overlay` et `display` (`allow-discrete`), pour animer aussi la fermeture sans bibliothèque ; sans prise en charge, l'ouverture est instantanée. Le voile reprend `color-mix(in srgb, var(--ink) 55%, transparent)` du tiroir. Sous 40rem, la boîte passe en feuille : pleine largeur, collée en bas, `padding-bottom` incluant `env(safe-area-inset-bottom)`, boutons empilés avec la confirmation au-dessus. La règle globale `prefers-reduced-motion` coupe déjà les transitions.

### 7. Textes

Les titres existants sont conservés tels quels. Les détails sont ajoutés aux vues. « Êtes-vous sûr ? » (`devise.views.fr.yml`, clé `are_you_sure`) est remplacé par « Supprimer votre compte ? » avec un détail dans la vue ; la clé n'est utilisée que par ce bouton.

## Risks / Trade-offs

- [Le clic sur le voile ferme aussi la boîte quand l'utilisateur relâche la souris hors d'elle après avoir sélectionné du texte] → On ne ferme que si `mousedown` et `click` ont tous deux lieu sur le voile.
- [`Turbo.config.forms.confirm` est une API récente de Turbo 8 : un changement de version majeur pourrait la déplacer] → Le contrôleur est le seul point d'accroche ; le test système de bout en bout échoue si le branchement casse.
- [Les tests système qui acceptaient l'alerte passent à une boîte maison, plus sensible au minutage] → Un assistant de test unique clique le bouton de la boîte et attend sa fermeture ; la boîte est détectée par son état ouvert, pas par un délai.
- [Chrome headless et popover/dialog : la couche supérieure est testée en conditions réelles] → La couverture de bout en bout est dans les tests système, pas seulement dans les tests d'intégration.
- [Une valeur de ton inconnue dans un attribut] → Traitée comme neutre.

## Migration Plan

Aucune donnée ni migration. Déploiement ordinaire ; retour arrière par `git revert`, les vues retrouvant l'alerte native.
