# Tasks

## 1. Lien de retour

- [x] 1.1 Dans `app/views/devise/confirmations/new.html.erb`, envelopper le paragraphe du lien « Retour à la connexion » dans `<div class="auth-links">…</div>`, comme dans `devise/shared/_links.html.erb`. Vérifier que la classe porte déjà l'espacement (`margin-top: 2rem`) et la taille (`0.9375rem`) dans `application.css`, sans nouvelle règle CSS.
- [x] 1.2 Dans `test/integration/manager_confirmation_test.rb`, compléter le test « the new link page renders » : la page contient `.auth-links a[href='/managers/sign_in']` avec le texte « Retour à la connexion ». Vérifier avec `bin/rails test test/integration/manager_confirmation_test.rb`.

## 2. Vérification d'ensemble

- [x] 2.1 Lancer `bin/rails test`, `bin/rails test:system` et `bin/rubocop`, et vérifier que tout passe.
- [x] 2.2 Faire une capture de `/managers/confirmation/new` et de `/managers/password/new` à 360 px et à 1000 px de large. Vérifier que le lien « Retour à la connexion » est détaché de la carte et de son ombre, avec le même espacement et la même taille que les liens de la page de mot de passe oublié.
