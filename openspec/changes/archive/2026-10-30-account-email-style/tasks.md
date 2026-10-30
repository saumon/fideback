# Tasks

## 1. Habillage commun

- [x] 1.1 Dans `config/initializers/devise.rb`, régler `config.parent_mailer = "ApplicationMailer"` (design §1). Vérifier avec `bin/rails runner` que `Devise::Mailer.superclass` vaut `ApplicationMailer`, et que la partie HTML de `Devise::Mailer.confirmation_instructions(Manager.first, "tok")` contient le bandeau (`linear-gradient`).
- [x] 1.2 Ajouter `test/mailers/devise_mailer_test.rb` (design §3). Pour l'activation, la réinitialisation et l'invitation, il vérifie dans la partie HTML l'en-tête « Fideback » et le bandeau. Vérifier avec `bin/rails test test/mailers`.

## 2. Réinitialisation du mot de passe

- [x] 2.1 Dans `devise.views.fr.yml`, changer `reset_password_instructions.greeting` en `"Bonjour %{recipient},"`. Dans `reset_password_instructions.html.erb`, passer `recipient: @resource.name` (design §2).
- [x] 2.2 Créer `app/views/devise/mailer/reset_password_instructions.text.erb`, calqué sur `confirmation_instructions.text.erb` (design §2).
- [x] 2.3 Compléter `devise_mailer_test.rb` : pour la réinitialisation et l'activation, vérifier les parties texte et HTML, la salutation « Bonjour Alice Manager, » dans les deux, et le lien complet dans la partie texte. Vérifier avec `bin/rails test test/mailers`.

## 3. Vérification d'ensemble

- [x] 3.1 Lancer `bin/rails test`, `bin/rails test:system` et `bin/rubocop`, et vérifier que tout passe.
- [x] 3.2 En développement, déclencher les trois e-mails suivants, puis les comparer dans `/letter_opener` avec une invitation de sondé : même en-tête, même bandeau, même carte, même bouton.
  - une inscription ;
  - un « mot de passe oublié » ;
  - un changement d'adresse.
