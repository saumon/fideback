# Design

## Context

- Une seule notification part aujourd'hui vers un manager : `CampaignMailer.completed`. Elle est envoyée par `Campaign#close_when_complete!`, après une mise à jour conditionnelle qui garantit un seul envoi. Les autres e-mails (lien de connexion, Devise, invitations, sondés) relèvent de l'authentification ou s'adressent à des tiers.
- « Mon compte » est la vue Devise `registrations/edit`. Toute mise à jour par `registration_path` exige `current_password`.
- Active Job tourne sur Solid Queue en production. Les e-mails partent avec `deliver_later`.
- Le chiffrement Active Record n'est pas encore configuré : aucune clé `active_record_encryption` n'existe. Les credentials sont séparés entre développement (`config/credentials.yml.enc` + `master.key`) et production (`config/credentials/production.yml.enc`).
- `filter_parameters` filtre déjà tout paramètre qui contient `token`.
- L'API Bot Telegram est HTTP/JSON : `https://api.telegram.org/bot<token>/<méthode>`. Un bot n'écrit qu'à une conversation qui lui a déjà écrit. Le `chat_id` d'une conversation privée ne se trouve que dans un message entrant. `getUpdates` renvoie 409 si un webhook est enregistré et ne garde les messages que 24 h.

## Goals / Non-Goals

**Goals:**
- Un point d'entrée unique pour les notifications destinées au manager, pour que les futurs événements n'aient qu'à s'y brancher.
- Pas de nouvelle gem ni de nouveau service à exploiter.
- Le token n'est jamais lisible en clair, ni en base, ni dans les journaux, ni dans les pages.

**Non-Goals:**
- Préférences par événement : l'interrupteur active ou coupe tout.
- Mise en forme riche (boutons inline, Markdown) : seulement du texte HTML Telegram simple avec un lien.
- Suivi de l'état de remise des messages (dernier succès ou dernier échec).

## Decisions

### 1. Données sur `managers`, pas de table dédiée
Trois colonnes : `telegram_bot_token` (texte, `encrypts`), `telegram_chat_id` (chaîne, car l'identifiant peut être négatif et dépasser 32 bits) et `telegram_enabled` (booléen, `false` par défaut, non nul). Ces données appartiennent au manager, sans historique, et sont supprimées avec lui.
*Alternative écartée :* une table `notification_channels`, trop générale pour un seul canal.

### 2. Chiffrement Active Record avec clés en credentials, ENV en priorité
On ajoute `active_record_encryption.{primary_key,deterministic_key,key_derivation_salt}` aux credentials de développement et de production (générés par `bin/rails db:encryption:init`). Les variables `ACTIVE_RECORD_ENCRYPTION_*` sont prioritaires, sur le modèle de `MailerSettings` (ENV → credentials). L'environnement de test utilise des clés fixes déclarées dans `config/environments/test.rb`. Le chiffrement n'est pas déterministe, puisqu'on ne recherche jamais par token.
*Alternative écartée :* stocker le token en clair, ce qui est inacceptable vu qu'il donne le contrôle complet du bot.

### 3. Contrôleur dédié, hors de Devise
`resource :telegram_setting, only: :update` avec deux actions membres, `detect` et `test_message` (par exemple `TelegramSettingsController`). Le formulaire de la section Telegram est un `form_with` distinct dans `registrations/edit`, sous le formulaire Devise. Les paramètres autorisés sont `telegram_bot_token`, `telegram_chat_id` et `telegram_enabled`. Un token vide est retiré des paramètres pour conserver le token existant. Le bouton « Détecter » est un second bouton de soumission du même formulaire, qui pointe vers `detect` par `formaction`. Il envoie ainsi le token saisi même s'il n'est pas enregistré.
*Alternative écartée :* passer par `registration_path`, qui imposerait le mot de passe actuel et mêlerait les validations Devise.

### 4. Détection : réponse Turbo Stream, rien n'est enregistré
`detect` appelle `getMe`, puis `getUpdates` sans `offset`, donc sans acquitter les messages. Il filtre les messages de type `message` dont `chat.type == "private"`, prend le plus récent et répond par un Turbo Stream. Ce flux remplace le champ `chat_id` prérempli et ajoute une ligne qui nomme l'interlocuteur (prénom et `@username`), ou un message d'erreur. Les erreurs sont traduites ainsi : 401 → token refusé, 409 → bot relié à un webhook (sans jamais appeler `deleteWebhook`), liste vide → écrire à `@<username du bot>`, réseau ou 5xx → Telegram injoignable. Le token utilisé est celui du formulaire, sinon le token enregistré.
*Alternative écartée :* un contrôleur Stimulus qui appelle Telegram depuis le navigateur. Le token passerait par le JavaScript client et la politique de sécurité du contenu (CSP) devrait autoriser `api.telegram.org`.

### 5. Client HTTP minimal `Telegram::BotClient`
Le client utilise `Net::HTTP` avec des délais de connexion et de lecture courts (5 s). Il expose `get_me`, `get_updates` et `send_message(chat_id, text)` avec `parse_mode: "HTML"` et `link_preview_options: { is_disabled: true }`. Il lève `Telegram::BotClient::Error` avec le code HTTP, la description et `retry_after`. Le token n'apparaît jamais dans les messages d'exception ni dans les journaux (on journalise la méthode et le code, pas l'URL).
*Alternative écartée :* la gem `telegram-bot-ruby`, une dépendance de trop pour trois appels.

### 6. Envoi par `TelegramMessageJob`, avec des tentatives seulement sur les erreurs temporaires
Le job reçoit le manager et le texte. Si Telegram est désactivé au moment de l'exécution, il ne fait rien. Il réessaie sur une erreur réseau, une erreur 5xx ou un 429 (`retry_on`, en attendant `retry_after` s'il est fourni, 5 tentatives). Sur les autres 4xx, il écrit un `Rails.logger.warn` (identifiant du manager, code, description) et s'arrête. Il ne modifie jamais la configuration.
Le message de test, lui, est envoyé **de façon synchrone** dans la requête, pour afficher le résultat au manager.

### 7. Point d'entrée `ManagerNotifier`
`ManagerNotifier.campaign_completed(campaign)` lance `CampaignMailer.completed(campaign).deliver_later`, puis met en file `TelegramMessageJob` si `manager.telegram_enabled?`. `Campaign#close_when_complete!` appelle ce point d'entrée à la place du mailer, après la même mise à jour conditionnelle, si bien que le message reste unique. Le texte Telegram est construit dans le notifier : nom de la campagne et nombre de réponses échappés avec `ERB::Util.html_escape`, puis lien `campaign_url`. Il reprend les formulations de l'e-mail.
*Alternative écartée :* un intercepteur ActionMailer qui doublerait tout e-mail sur Telegram. Il enverrait aussi les e-mails d'authentification, ce que la spec exclut.

### 8. Validations
- Token : `/\A\d+:[A-Za-z0-9_-]{30,}\z/`, seulement quand il est présent.
- `chat_id` : `/\A-?\d+\z/`, seulement quand il est présent.
- `telegram_enabled` exige la présence des deux.
Les messages d'erreur sont en français, dans `config/locales`, sur le modèle des validations existantes.

### 9. Vue
La section suit le style coloré du reste de l'application (classes existantes, icône, `prefers-reduced-motion`). L'interrupteur est une case à cocher stylée. Le token enregistré s'affiche sous la forme `••••1234`. Le guide est un `<details>`, ouvert si le token ou le `chat_id` manque. Les boutons « Détecter » et « Envoyer un message de test » sont dans la section ; le second n'apparaît que si la configuration est enregistrée.

## Risks / Trade-offs

- [Clés de chiffrement perdues ou changées] → les tokens deviennent illisibles. On intercepte `ActiveRecord::Encryption::Errors::Decryption` dans le job et dans la vue, on considère le token comme absent et on le journalise. Le manager n'a qu'à ressaisir son token.
- [Clés absentes en production au déploiement] → le premier enregistrement d'un token échoue. La tâche de déploiement ajoute les clés aux credentials de production avant la mise en ligne. L'échec de chargement est vérifié par un test.
- [Un inconnu écrit au bot juste avant la détection] → son `chat_id` serait proposé. Le nom de l'interlocuteur est affiché avant tout enregistrement, et le message de test confirme le bon destinataire.
- [`getUpdates` partagé avec un autre consommateur de longue durée (n8n en polling)] → la détection peut « voler » un message ou en manquer un. Sans `offset`, on n'acquitte rien, donc l'impact est nul pour l'autre consommateur.
- [Message de test synchrone qui bloque la requête] → borné par les délais de 5 s.
- [Notifications Telegram retentées en boucle] → 5 tentatives au maximum, et uniquement sur les erreurs temporaires.

## Migration Plan

1. Générer les clés (`bin/rails db:encryption:init`) et les ajouter aux credentials de développement et de production.
2. Migration additive des trois colonnes, sans réécriture de données. Le retour arrière se fait par une migration inverse ; aucune donnée existante n'est touchée.
3. Déployer. Telegram reste désactivé pour tous les managers tant qu'ils ne l'ont pas configuré.
