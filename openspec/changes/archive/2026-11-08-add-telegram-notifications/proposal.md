## Why

Un manager n'apprend qu'une campagne est terminée qu'en consultant ses e-mails. Beaucoup utilisent Telegram au quotidien et veulent y recevoir les notifications de Fideback, en plus des e-mails. Le manager branche son propre bot Telegram, créé avec BotFather. Fideback n'expose ni webhook ni interrogation périodique : il se contente d'envoyer des messages par ce bot.

## What Changes

- La page « Mon compte » reçoit une section « Notifications Telegram », séparée du formulaire Devise. Elle s'enregistre sans demander le mot de passe actuel. Elle contient :
  - le **token du bot**, stocké chiffré et jamais réaffiché en clair ;
  - l'**identifiant de conversation** (chat_id), modifiable à la main ;
  - un **interrupteur** activer/désactiver qui conserve la configuration ;
  - un bouton **« Détecter »** : sur demande du manager, Fideback vérifie le token saisi (`getMe`) et lit une seule fois les messages récents du bot (`getUpdates`, sans les acquitter). Il préremplit le chat_id avec la conversation privée la plus récente et affiche son nom pour que le manager vérifie. Rien n'est enregistré à ce moment-là ;
  - un bouton **« Envoyer un message de test »** ;
  - un **mini-guide** repliable (BotFather, `/newbot`, token, `/start`, Détecter, test, cas d'un bot déjà relié à un webhook n8n). Il est ouvert par défaut tant que Telegram n'est pas configuré.
- Les erreurs de la détection sont expliquées au manager : token refusé, aucun message récent, bot relié à un webhook (409). Fideback ne supprime jamais le webhook d'un bot.
- Les notifications destinées au manager passent par un point d'entrée unique. Il envoie l'e-mail, et le message Telegram si l'intégration est active. Le seul événement concerné aujourd'hui est la **clôture automatique d'une campagne**.
- Les e-mails d'authentification (lien de connexion, activation, réinitialisation) et les e-mails envoyés aux sondés ou aux invités ne passent **jamais** par Telegram.
- Un envoi Telegram en échec n'est pas signalé au manager. Il est écrit dans le journal, et il ne change ni l'e-mail ni l'état de la campagne.

## Capabilities

### New Capabilities

- `telegram-notifications` : configuration par le manager de son bot Telegram (token, chat_id, interrupteur, détection, message de test, guide) et envoi des notifications du manager par ce bot.

### Modified Capabilities

- `feedback-campaigns` : la notification de clôture automatique part aussi sur Telegram quand le manager l'a activé, sans changer l'e-mail existant.

## Impact

- Base de données : colonnes `telegram_bot_token` (chiffrée), `telegram_chat_id` et `telegram_enabled` sur `managers`.
- Chiffrement Active Record : des clés `active_record_encryption` à ajouter aux credentials (développement et production) et une configuration pour les tests.
- Nouveau client HTTP minimal pour l'API Bot Telegram (`Net::HTTP`, sans nouvelle gem) et un job Active Job (Solid Queue) pour l'envoi.
- `config/routes.rb`, un nouveau contrôleur pour la section Telegram, et la vue `devise/registrations/edit.html.erb`.
- `Campaign#close_when_complete!` passe par le point d'entrée des notifications du manager.
- Hors périmètre : webhook ou `getUpdates` automatique, commandes envoyées au bot, notifications Telegram aux sondés, bot commun à toute l'instance, signalement des échecs au manager.
