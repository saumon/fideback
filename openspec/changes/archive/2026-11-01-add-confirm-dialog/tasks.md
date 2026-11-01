# Tasks

## 1. Boîte et branchement

- [x] 1.1 Créer le partiel `layouts/_confirm_dialog.html.erb` (`<dialog>` avec badge, titre, détail, boutons « Non, revenir » et confirmation, `aria-labelledby` et `aria-describedby`) et le rendre dans `layouts/application` et `layouts/respondent`, puis vérifier par un test d'intégration que la boîte est présente dans une page de manager et dans une page de sondé
- [x] 1.2 Créer le contrôleur Stimulus `confirm_dialog` : branche `Turbo.config.forms.confirm` à la connexion et le retire à la déconnexion, remplit titre, détail, icône, ton et libellé de confirmation depuis le déclencheur puis le formulaire, ouvre avec `showModal()`, renvoie une promesse `true`/`false`, et vérifier qu'une confirmation envoie le formulaire et qu'un refus ne l'envoie pas (test système de l'étape 4)
- [x] 1.3 Gérer les issues : « Non, revenir », Échap et clic sur le voile (`mousedown` et `click` sur le voile) renvoient `false` ; le focus initial va sur « Non, revenir » en ton danger et sur la confirmation sinon ; le focus revient sur le déclencheur ; une boîte ouverte est fermée avant la mise en cache de Turbo
- [x] 1.4 Replier sur `window.confirm` quand `showModal` n'existe pas, et vérifier ce repli par un test système qui retire `showModal` avant le clic

## 2. Style

- [x] 2.1 Ajouter à `application.css` la section de la boîte : bordure, ombre et pastille selon le ton, voile, animation d'entrée et de sortie (`@starting-style`, transitions `allow-discrete`), boutons sur `.btn`, `.btn-primary` et `.btn-solid-danger`, et vérifier à l'écran à 1400 px et 380 px
- [x] 2.2 Ajouter la mise en page mobile (sous 40rem : feuille en bas, pleine largeur, boutons empilés, marge de sécurité du bas) et vérifier qu'aucun défilement horizontal n'apparaît à 380 px
- [x] 2.3 Vérifier que `prefers-reduced-motion` supprime le glissement et le rebond de la boîte, par une capture avec l'émulation du mouvement réduit

## 3. Vues et textes

- [x] 3.1 Ajouter détail, ton et icône aux déclencheurs de `campaigns/show` (lancer, clôturer, supprimer, renvoyer) et vérifier par un test d'intégration que chaque attribut est rendu
- [x] 3.2 Ajouter détail, ton et icône à `respondent_forms/show` (soumission) et à `admin/users/index` (renvoyer, annuler une invitation) et vérifier par un test d'intégration
- [x] 3.3 Remplacer « Êtes-vous sûr ? » par « Supprimer votre compte ? » dans `devise.views.fr.yml`, ajouter le détail et le ton danger à `devise/registrations/edit`, retirer le `data-confirm` inutile, et vérifier par un test d'intégration sur le bouton de la page de compte

## 4. Tests système

- [x] 4.1 Ajouter à `ApplicationSystemTestCase` un assistant qui attend la boîte ouverte, clique son bouton de confirmation ou « Non, revenir » et attend sa fermeture, puis remplacer les quatre `accept_confirm` de `feedback_journey_test` et `toasts_test` et vérifier que ces tests passent
- [x] 4.2 Créer `test/system/confirm_dialog_test.rb` : titre et détail affichés sans alerte native, libellé de confirmation repris du bouton, refus par « Non, revenir », Échap et clic sur le voile (l'action n'a pas lieu), retour du focus, focus initial en ton danger et en ton neutre, Tab qui reste dans la boîte
- [x] 4.3 Ajouter à ce test un parcours mobile (fenêtre de 380 px : boîte pleine largeur en bas, boutons empilés) et le repli sur l'alerte native de la tâche 1.4, puis lancer `bin/rails test:system` complet et vérifier qu'il passe

## 5. Documentation et vérifications

- [x] 5.1 Documenter la boîte dans `docs/fonctionnement.md` (un paragraphe : actions concernées, ton danger, clavier, mobile) et la mentionner en une ligne dans *Fonctionnalités* du README ; vérifier que les liens du README fonctionnent
- [x] 5.2 Vérifier avec `openspec validate add-confirm-dialog --strict`, puis `bin/rails test`, `bin/rubocop`, `bin/rails test:system` et `bin/ci` au vert

## Workflow follow-up

- Archiver le changement avec `/opsx:archive` (synchronisation de `confirm-dialog` vers les spécifications de référence), puis terminer avec `/saumon-finish`.
