# Tasks

## 1. Libellé du bouton

- [x] 1.1 Dans `config/locales/devise.views.fr.yml`, remplacer la valeur de `devise.passwords.new.send_me_reset_password_instructions` par « Envoyez-moi les instructions ». Vérifier qu'aucune autre clé de traduction n'utilise l'ancien libellé (`grep -rn "réinitialiser mon mot de passe" app config`).
- [x] 1.2 Dans `test/integration/manager_auth_test.rb`, ajouter un test : la page `new_manager_password_path` affiche un bouton `input[type=submit][value='Envoyez-moi les instructions']`. Vérifier avec `bin/rails test test/integration/manager_auth_test.rb`.

## 2. Vérification d'ensemble

- [x] 2.1 Lancer `bin/rails test`, `bin/rails test:system` et `bin/rubocop`, et vérifier que tout passe.
- [x] 2.2 Faire une capture de `/managers/password/new` à 360 px et à 1000 px de large. Vérifier que le bouton tient entièrement dans la carte du formulaire, sans texte coupé.
