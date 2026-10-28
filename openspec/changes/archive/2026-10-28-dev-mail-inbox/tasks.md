# Tasks

## 1. Interception des emails en développement

- [x] 1.1 Ajouter `gem "letter_opener_web"` au `group :development` du Gemfile, lancer `bundle install` et vérifier que `Gemfile.lock` le contient
- [x] 1.2 Dans `config/environments/development.rb`, définir `config.action_mailer.delivery_method = :letter_opener_web` et vérifier que `bin/rails runner 'puts ActionMailer::Base.delivery_method'` affiche `letter_opener_web` en développement
- [x] 1.3 Dans `config/routes.rb`, monter `LetterOpenerWeb::Engine` sur `/letter_opener` sous `if Rails.env.development?` et vérifier que `bin/rails routes` liste la route en développement, mais pas avec `RAILS_ENV=test`
- [x] 1.4 Vérifier que `bin/rails test` passe toujours (aucun chargement de l'engine en test)

## 2. Lien en bas de page (développement uniquement)

- [x] 2.1 Créer `app/views/layouts/_dev_footer.html.erb` : `<footer class="dev-footer">` avec un lien `target="_blank"` vers `letter_opener_web.letters_path`, le tout sous `if Rails.env.development?`
- [x] 2.2 Rendre le partial en bas du `<body>` de `application.html.erb` et de `respondent.html.erb`, et vérifier à la main en développement que le lien apparaît sur une page manager et sur la page d'un sondé
- [x] 2.3 Ajouter le style `.dev-footer` dans `app/assets/stylesheets/application.css` et vérifier visuellement qu'il reste discret
- [x] 2.4 Ajouter un test d'intégration vérifiant qu'en environnement `test` la page d'accueil et le formulaire sondé ne contiennent pas `/letter_opener`, et vérifier qu'il passe

## 3. Vérification de bout en bout

- [x] 3.1 En développement, lancer une campagne, vérifier que l'invitation apparaît dans `/letter_opener` et que son lien personnel mène au formulaire sondé
- [x] 3.2 Lancer `bin/rubocop` et `bin/brakeman` et vérifier l'absence de nouvelle alerte
