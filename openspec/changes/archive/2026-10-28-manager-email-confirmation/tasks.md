# Tasks

## 1. Réglages mail (mail-delivery)

- [x] 1.1 Créer `config/mailer_settings.rb` (`Fideback::MailerSettings` : `smtp_settings`, `smtp_configured?`, `default_url_options`, `mailer_sender`, lecture tolérante des credentials) et le requérir depuis `config/application.rb` ; vérifier par `test/lib/mailer_settings_test.rb` (ENV prioritaire sur credentials, ENV vide ignorée, config partielle = non configuré, `SMTP_ENABLED=false`, repli du sender)
- [x] 1.2 Brancher l'expéditeur unique : `config.mailer_sender` de `devise.rb` et `default from:` d'`ApplicationMailer` lisent `mailer_sender` ; vérifier par un test de mailer comparant l'expéditeur d'une invitation et d'un mail Devise
- [x] 1.3 Configurer `production.rb` (SMTP si complet, sinon `raise_delivery_errors` et avertissement au démarrage nommant « non configuré » ou « désactivé ») et `default_url_options` ; vérifier avec `RAILS_ENV=production bin/rails runner` avec et sans variables `SMTP_*`
- [x] 1.4 Configurer `development.rb` (SMTP seulement si complet, sinon letter_opener_web comme avant ; `default_url_options` via le module) ; vérifier que `test/integration/dev_mail_inbox_test.rb` passe toujours et que `.env` (`APP_HOST`, `APP_PORT`) donne les mêmes liens qu'avant
- [x] 1.5 Mettre à jour `config/deploy.yml` (`SMTP_*` en `env.clear`, `SMTP_PASSWORD` en secret via `.kamal/secrets`) et documenter les variables dans le README ; vérifier que `bin/kamal config` s'exécute sans erreur

## 2. Activation du compte (manager-auth)

- [x] 2.1 Écrire la migration (colonnes `confirmation_token` avec index unique, `confirmed_at`, `confirmation_sent_at`, `unconfirmed_email`, rattrapage de `confirmed_at` pour les managers existants, `up`/`down`) ; vérifier avec `bin/rails db:migrate` puis `db:rollback`, et que `db/schema.rb` est à jour
- [x] 2.2 Ajouter `:confirmable` à `Manager`, `confirm_within = 24.hours` et `resend_activation!` (vide le token avant `resend_confirmation_instructions`) ; confirmer les fixtures `alice` et `bob` ; vérifier par `test/models/manager_test.rb` (un renvoi invalide l'ancien token) et par la suite existante toujours verte
- [x] 2.3 Surcharger `Managers::RegistrationsController` (`after_inactive_sign_up_path_for` vers la connexion) et déclarer les contrôleurs dans `devise_for :managers` ; adapter le test d'inscription (compte inactif, e-mail envoyé, pas de session, redirection vers la connexion) et vérifier qu'une adresse déjà prise n'envoie rien
- [x] 2.4 Créer `Managers::ConfirmationsController` (`show` avec les cas expiré / déjà actif / inconnu, `create` à réponse identique et cooldown de 5 min) ; vérifier par `test/integration/manager_confirmation_test.rb` : lien valide, expiré, déjà utilisé, inconnu, lien remplacé par un renvoi, renvoi (inactif, actif, inconnu, trop rapide) avec réponse identique
- [x] 2.5 Écrire les vues : e-mail de confirmation HTML et texte dans le style des e-mails existants, page de renvoi avec le message du cas d'échec, lien « Vous n'avez pas reçu les instructions » ; messages fr dans `config/locales` ; vérifier le rendu des deux gabarits dans un test de mailer et la page via un test d'intégration
- [x] 2.6 Vérifier le refus de connexion : compte inactif avec bon mot de passe = message « activer votre compte », avec mauvais mot de passe = message générique ; vérifier par test d'intégration, et que le manager existant migré se connecte normalement

## 3. Vérification d'ensemble

- [x] 3.1 Parcours complet dans la suite système (`test/system/feedback_journey_test.rb`) : inscription, lecture du mail, clic sur le lien, connexion, création de campagne ; vérifier que `bin/rails test` et `bin/rails test:system` passent
- [x] 3.2 Parcours manuel en développement : l'e-mail apparaît dans `/letter_opener` avec un lien fonctionnel sur `APP_HOST` ; lancer `bin/rubocop` et `bin/brakeman` sans nouvelle alerte
