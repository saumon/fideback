# Spec Delta

## Purpose

Permettre à un manager de recevoir les notifications de Fideback dans Telegram, en plus des e-mails, par un bot qu'il a créé lui-même. Fideback ne reçoit rien de Telegram : il ne fait qu'envoyer des messages.

## ADDED Requirements

### Requirement: Section Telegram dans la page du compte
Le système SHALL proposer, dans la page « Mon compte » du manager connecté, une section « Notifications Telegram » qui s'enregistre indépendamment des informations du compte et sans demander le mot de passe actuel. Elle porte le token du bot, l'identifiant de conversation et un interrupteur d'activation.

#### Scenario: Enregistrement sans mot de passe
- **WHEN** un manager connecté saisit un token et un identifiant de conversation dans la section Telegram et enregistre
- **THEN** la configuration est enregistrée sans que son mot de passe actuel soit demandé, et son nom, son e-mail et son mot de passe restent inchangés

#### Scenario: Accès réservé
- **WHEN** un visiteur non connecté tente d'enregistrer une configuration Telegram
- **THEN** il est redirigé vers la connexion et aucune configuration n'est modifiée

#### Scenario: Configuration propre au manager
- **WHEN** un manager enregistre sa configuration Telegram
- **THEN** seule sa propre configuration change, celle des autres managers reste intacte

### Requirement: Token du bot protégé
Le système MUST stocker le token du bot chiffré et ne jamais le réafficher en clair. Un champ de token laissé vide à l'enregistrement MUST conserver le token existant.

#### Scenario: Token enregistré masqué
- **WHEN** un manager dont le token se termine par « 1234 » rouvre la page de son compte
- **THEN** la section indique qu'un token est enregistré sous une forme masquée qui ne montre que « 1234 », et le champ du token est vide

#### Scenario: Token laissé vide
- **WHEN** un manager ayant un token enregistré modifie l'identifiant de conversation sans ressaisir le token
- **THEN** le token enregistré est conservé

#### Scenario: Token jamais lisible en clair
- **WHEN** un token est enregistré
- **THEN** sa valeur en clair n'apparaît ni dans la base de données, ni dans les pages, ni dans les journaux de requêtes

### Requirement: Validation de la configuration
Le système SHALL n'accepter qu'un token au format d'un token de bot Telegram et un identifiant de conversation numérique, éventuellement négatif. Les notifications MUST ne pouvoir être activées que si le token et l'identifiant sont tous deux renseignés.

#### Scenario: Token mal formé
- **WHEN** un manager enregistre le token « abc »
- **THEN** l'enregistrement est refusé avec un message en français indiquant que le token n'a pas le format attendu

#### Scenario: Identifiant non numérique
- **WHEN** un manager enregistre l'identifiant de conversation « @jdupont »
- **THEN** l'enregistrement est refusé avec un message en français indiquant que l'identifiant doit être numérique

#### Scenario: Activation incomplète
- **WHEN** un manager active les notifications alors que l'identifiant de conversation est vide
- **THEN** l'enregistrement est refusé et les notifications restent désactivées

### Requirement: Interrupteur d'activation
Le système SHALL permettre au manager d'activer ou de désactiver les notifications Telegram sans effacer le token ni l'identifiant de conversation. Les notifications sont désactivées tant que le manager ne les a pas activées.

#### Scenario: Désactivation
- **WHEN** un manager désactive ses notifications Telegram
- **THEN** son token et son identifiant de conversation restent enregistrés, et aucune notification ne part sur Telegram

#### Scenario: Réactivation
- **WHEN** un manager réactive ses notifications sans rien ressaisir
- **THEN** les notifications suivantes partent de nouveau sur Telegram avec la configuration enregistrée

#### Scenario: Valeur par défaut
- **WHEN** un manager n'a jamais touché à la section Telegram
- **THEN** ses notifications Telegram sont désactivées

### Requirement: Détection de la conversation à la demande
Le système SHALL, quand le manager clique sur « Détecter », vérifier le token saisi auprès de Telegram puis lire une seule fois les messages récents reçus par le bot, sans les acquitter, pour préremplir l'identifiant de conversation. La détection MUST ne rien enregistrer.

#### Scenario: Conversation trouvée
- **WHEN** le manager a écrit « /start » à son bot puis clique sur « Détecter » avec un token valide
- **THEN** le champ de l'identifiant est prérempli avec l'identifiant de cette conversation privée, et le nom et le nom d'utilisateur Telegram de l'interlocuteur sont affichés pour vérification

#### Scenario: Token pas encore enregistré
- **WHEN** le manager saisit un token sans enregistrer puis clique sur « Détecter »
- **THEN** la détection utilise le token saisi, et ni le token ni l'identifiant ne sont enregistrés

#### Scenario: Plusieurs conversations
- **WHEN** plusieurs personnes ont écrit au bot, dans des conversations privées et dans un groupe
- **THEN** les messages de groupe sont ignorés et la conversation privée la plus récente est retenue, avec son nom affiché

#### Scenario: Token refusé
- **WHEN** Telegram refuse le token
- **THEN** le message « Token refusé par Telegram » est affiché et l'identifiant n'est pas modifié

#### Scenario: Aucun message récent
- **WHEN** le bot n'a reçu aucun message privé récent
- **THEN** un message invite le manager à écrire à son bot, en le nommant par son nom d'utilisateur, puis à réessayer

#### Scenario: Bot relié à un webhook
- **WHEN** Telegram répond que le bot reçoit ses messages par webhook
- **THEN** un message explique que ce bot est déjà relié à un webhook (par exemple n8n) et invite à saisir l'identifiant à la main, et le webhook du bot n'est pas modifié

#### Scenario: Telegram injoignable
- **WHEN** Telegram ne répond pas ou renvoie une erreur serveur
- **THEN** un message indique que Telegram est injoignable pour le moment et l'identifiant n'est pas modifié

### Requirement: Aucune réception de messages Telegram
Le système MUST NOT exposer de webhook Telegram, enregistrer ou supprimer un webhook sur le bot d'un manager, ni interroger les messages du bot autrement que lors d'une détection demandée par le manager.

#### Scenario: Pas d'interrogation automatique
- **WHEN** aucun manager ne clique sur « Détecter »
- **THEN** le système n'interroge jamais les messages reçus par les bots

#### Scenario: Pas de route de réception
- **WHEN** Telegram ou un tiers envoie une requête vers l'application pour lui transmettre un message de bot
- **THEN** aucune route de l'application ne la traite comme un message Telegram

### Requirement: Message de test
Le système SHALL proposer un bouton « Envoyer un message de test » qui envoie, avec la configuration enregistrée, un message de test à la conversation, que les notifications soient activées ou non, et SHALL afficher le résultat au manager.

#### Scenario: Test réussi
- **WHEN** un manager dont le token et l'identifiant sont enregistrés clique sur « Envoyer un message de test »
- **THEN** un message en français annonçant que Fideback est bien relié arrive dans sa conversation Telegram, et une confirmation est affichée

#### Scenario: Test en échec
- **WHEN** Telegram refuse l'envoi, par exemple parce que le manager n'a jamais écrit au bot ou l'a bloqué
- **THEN** un message d'erreur en français est affiché au manager

#### Scenario: Configuration incomplète
- **WHEN** le token ou l'identifiant n'est pas enregistré
- **THEN** le bouton de test n'est pas proposé

### Requirement: Guide de configuration
Le système SHALL afficher dans la section Telegram un guide repliable qui décrit la création du bot avec BotFather (`/newbot`, nom, nom d'utilisateur finissant par « bot », copie du token), l'envoi de « /start » au bot, la détection, le message de test, et le cas d'un bot déjà relié à un webhook. Le guide MUST être déplié tant que Telegram n'est pas configuré.

#### Scenario: Première visite
- **WHEN** un manager sans configuration Telegram ouvre la page de son compte
- **THEN** le guide est déplié

#### Scenario: Configuration en place
- **WHEN** un manager dont le token et l'identifiant sont enregistrés ouvre la page de son compte
- **THEN** le guide est replié et peut être déplié

### Requirement: Envoi des notifications du manager sur Telegram
Le système SHALL envoyer sur Telegram, en plus de l'e-mail, chaque notification destinée au manager lorsque ses notifications Telegram sont activées. Le message MUST reprendre l'essentiel de l'e-mail et un lien vers la page concernée. Les e-mails d'authentification et ceux adressés à d'autres personnes MUST NOT être envoyés sur Telegram.

#### Scenario: Notifications activées
- **WHEN** une notification destinée au manager part alors que ses notifications Telegram sont activées
- **THEN** il reçoit l'e-mail et un message Telegram

#### Scenario: Notifications désactivées
- **WHEN** une notification destinée au manager part alors que ses notifications Telegram sont désactivées
- **THEN** il reçoit seulement l'e-mail

#### Scenario: E-mails d'authentification
- **WHEN** un lien de connexion, un e-mail d'activation ou de réinitialisation du mot de passe est envoyé à un manager dont Telegram est activé
- **THEN** aucun message Telegram n'est envoyé

#### Scenario: Texte fourni par les utilisateurs
- **WHEN** le message reprend un nom de campagne contenant « <b> » ou « & »
- **THEN** ces caractères apparaissent tels quels dans Telegram, sans être interprétés comme de la mise en forme

### Requirement: Échec d'envoi silencieux pour le manager
Le système MUST NOT signaler au manager l'échec d'un envoi de notification Telegram. L'échec MUST être écrit dans le journal sans le token, et MUST NOT empêcher l'envoi de l'e-mail ni annuler l'action qui a déclenché la notification. Une erreur temporaire de Telegram SHALL donner lieu à de nouvelles tentatives.

#### Scenario: Envoi refusé
- **WHEN** Telegram refuse définitivement l'envoi, par exemple parce que le bot a été bloqué ou que le token a été révoqué
- **THEN** l'échec est écrit dans le journal sans le token, aucun message n'est affiché au manager, l'e-mail est envoyé et la configuration reste inchangée

#### Scenario: Erreur temporaire
- **WHEN** Telegram est injoignable, renvoie une erreur serveur ou limite le débit
- **THEN** l'envoi est retenté plus tard, en respectant le délai demandé par Telegram s'il en indique un
