# Tasks

## 1. Vue

- [x] 1.1 Dans `_new_contact_fields.html.erb`, ajouter la case cochée, non interactive, sans `name`, `aria-hidden`, avant les champs ; vérifier qu'aucun paramètre supplémentaire n'est soumis (test d'intégration sur `campaigns`)

## 2. Styles

- [x] 2.1 Habiller `.contact` comme `.pick:has(:checked)` (bordure, fond teinté, ombre) en partageant les déclarations ; vérifier dans le navigateur sur les sections managés (safran) et sondés (rose)
- [x] 2.2 Ajouter la colonne de la case à la grille `.contact`, desktop et mobile ; vérifier l'affichage à 375 px de large
- [x] 2.3 Vérifier qu'une ligne en erreur garde la bordure `--danger` sur les champs

## 3. Tests

- [x] 3.1 Ajuster ou ajouter un test d'intégration qui vérifie la présence de la case cochée dans la ligne ; `bin/rails test` passe
- [x] 3.2 Vérifier que `test/system/feedback_journey_test.rb` passe toujours après un clic sur « Nouveau contact »
