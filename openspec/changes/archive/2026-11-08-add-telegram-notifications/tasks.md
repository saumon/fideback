# Tasks

## 1. Chiffrement et données

- [x] 1.1 Configurer le chiffrement Active Record : clés lues depuis `ACTIVE_RECORD_ENCRYPTION_*` puis depuis les credentials (`active_record_encryption.*`), et clés fixes dans `config/environments/test.rb`. Générer les clés avec `bin/rails db:encryption:init` et les ajouter aux credentials de développement et de production. Vérifier que `bin/rails runner 'p ActiveRecord::Encryption.config.primary_key.present?'` affiche `true` en développement et en test.
- [x] 1.2 Ajouter la migration des colonnes `telegram_bot_token` (texte), `telegram_chat_id` (chaîne) et `telegram_enabled` (booléen, `false` par défaut, non nul) sur `managers`. Vérifier par `bin/rails db:migrate` puis par `db/schema.rb`.
- [x] 1.3 Dans `Manager` : `encrypts :telegram_bot_token`, les validations de format (token, chat_id), l'activation qui exige les deux valeurs, un helper de token masqué (`••••1234`), et `telegram_configured?` qui renvoie faux si le token ne se déchiffre pas. Messages d'erreur en français dans `config/locales`. Vérifier dans `test/models/manager_test.rb` : formats refusés, activation incomplète refusée, valeur par défaut désactivée, valeur en clair absente de la colonne en base, masque.

## 2. Client Telegram

- [x] 2.1 Créer `Telegram::BotClient` (`Net::HTTP`, délais de 5 s) avec `get_me`, `get_updates` (sans `offset`) et `send_message` (`parse_mode: "HTML"`, aperçu de lien désactivé), et une erreur `Telegram::BotClient::Error` qui porte le code, la description et `retry_after`. Le token n'apparaît jamais dans les messages ni dans les journaux. Vérifier dans `test/services/telegram_bot_client_test.rb`, avec `Net::HTTP` bouchonné : requêtes construites, 401, 409, 429 avec `retry_after`, délai dépassé, token absent du message d'erreur.
- [x] 2.2 Ajouter un sélecteur de conversation (fonction ou méthode du client) qui retient la conversation privée la plus récente d'une réponse `getUpdates` et ignore les groupes. Vérifier par des tests unitaires : liste vide, groupes seuls, plusieurs conversations privées.

## 3. Envoi des notifications

- [x] 3.1 Créer `TelegramMessageJob` : ne fait rien si Telegram est désactivé ou si le token ne se déchiffre pas ; `retry_on` sur les erreurs réseau, 5xx et 429 (attente de `retry_after`, 5 tentatives) ; `Rails.logger.warn` sans le token sur les autres 4xx, sans modifier la configuration. Vérifier dans `test/jobs/telegram_message_job_test.rb` : envoi, désactivé, nouvelle tentative sur 429 ou 5xx, abandon et journalisation sur 403, token absent du journal.
- [x] 3.2 Créer `ManagerNotifier.campaign_completed(campaign)` : il met en file l'e-mail existant et, si Telegram est activé, `TelegramMessageJob` avec un texte qui reprend l'e-mail (nom de la campagne échappé, nombre de réponses, lien `campaign_url`). Remplacer l'appel du mailer dans `Campaign#close_when_complete!`. Vérifier dans `test/integration/campaign_auto_close_test.rb` et un test du notifier : e-mail et job si activé, e-mail seul sinon, aucun envoi à la clôture manuelle, un seul job lors de soumissions simultanées, texte qui contient « <b> » et « & » échappés.

## 4. Section « Notifications Telegram » de la page du compte

- [x] 4.1 Ajouter les routes `resource :telegram_setting, only: :update` avec `post :detect` et `post :test_message`, et le contrôleur authentifié. `update` conserve le token quand le champ est vide et répond par une redirection 303 vers la page du compte avec une notice, ou réaffiche le formulaire avec les erreurs. Vérifier dans `test/integration/telegram_settings_test.rb` : enregistrement sans mot de passe, token conservé, désactivation qui garde la configuration, anonyme redirigé, autres managers intacts, token absent des journaux de requêtes (paramètre filtré).
- [x] 4.2 Implémenter `detect` (token du formulaire, sinon le token enregistré ; `getMe` puis `getUpdates` ; réponse Turbo Stream qui remplace le champ `chat_id` et affiche l'interlocuteur ou l'erreur en français) sans rien enregistrer et sans jamais appeler `deleteWebhook`. Vérifier par des tests d'intégration avec le client bouchonné : conversation trouvée, token non enregistré utilisé puis non persisté, 401, liste vide (nom du bot cité), 409, Telegram injoignable.
- [x] 4.3 Implémenter `test_message` (envoi synchrone avec la configuration enregistrée, notice de succès ou alerte d'erreur en français, que Telegram soit activé ou non). Vérifier par des tests d'intégration : succès, 403 affiché, configuration incomplète refusée.
- [x] 4.4 Ajouter la section dans `app/views/devise/registrations/edit.html.erb` : formulaire distinct, token masqué, champ `chat_id`, interrupteur, bouton « Détecter » (`formaction` vers `detect`), bouton « Envoyer un message de test » affiché seulement si la configuration est complète, et guide `<details>` (BotFather, `/newbot`, nom d'utilisateur en « bot », token, `/start`, Détecter, test, bot relié à un webhook n8n → @userinfobot) ouvert tant que Telegram n'est pas configuré. Style coloré du projet, `prefers-reduced-motion` respecté. Vérifier par des tests d'intégration du rendu : guide ouvert ou fermé, masque, bouton de test présent ou absent.
- [x] 4.5 Ajouter un test système dans `test/system/telegram_settings_test.rb` (client bouchonné) : le manager colle un token, clique sur « Détecter », voit le nom et le champ prérempli, active, enregistre, puis envoie un message de test et voit la confirmation. Vérifier qu'il passe avec `bin/rails test:system`.

## 5. Vérifications de non-régression

- [x] 5.1 Vérifier qu'aucune route de l'application ne reçoit de message Telegram (`bin/rails routes | grep -i telegram` ne montre que `update`, `detect` et `test_message`) et que les e-mails d'authentification ne mettent en file aucun `TelegramMessageJob` (test d'intégration sur le lien de connexion d'un manager dont Telegram est activé).
- [x] 5.2 Mettre à jour le README (section des fonctionnalités et des secrets de déploiement : clés `ACTIVE_RECORD_ENCRYPTION_*` ou credentials) et vérifier que les commandes documentées fonctionnent telles qu'écrites.
- [x] 5.3 Lancer `bin/ci` et `bin/rails test:system` (Ruby de `/usr/local/rvm/rubies/ruby-3.4.6/bin`) et `openspec validate add-telegram-notifications --strict`, et confirmer que tout passe.

## Workflow follow-up

- Vérifier que les clés de chiffrement sont présentes dans les credentials de production avant `/saumon-deploy`.
- Archiver le change une fois la revue passée (`/opsx:archive`).
