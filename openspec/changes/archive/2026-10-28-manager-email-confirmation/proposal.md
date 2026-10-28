# Proposal

## Why

Aujourd'hui, n'importe qui peut créer un compte manager avec une adresse qu'il ne possède pas : l'adresse n'est jamais vérifiée, alors que c'est elle qui reçoit les e-mails de réinitialisation de mot de passe. Un e-mail de validation à la création de compte garantit que l'adresse appartient bien à la personne qui s'inscrit. Cet e-mail est le premier dont le lien est indispensable au fonctionnement : il faut donc aussi pouvoir configurer l'envoi SMTP en production, qui n'est pas configuré aujourd'hui.

## What Changes

- **BREAKING** L'inscription crée un compte inactif et ne connecte plus le manager ; elle envoie un e-mail contenant un lien d'activation valable 24 h.
- Le lien d'activation active le compte puis redirige vers la page de connexion (il ne connecte pas).
- Un manager dont le compte n'est pas activé ne peut pas se connecter et est informé qu'il doit activer son compte.
- Une page permet de demander un nouvel e-mail d'activation : réponse identique quelle que soit l'adresse, un e-mail par adresse toutes les 5 minutes, et chaque renvoi invalide les liens précédents.
- Un lien invalide mène à cette page avec un message distinct selon le cas : expiré, compte déjà actif, lien inconnu.
- Les comptes existants au moment de la mise en production sont considérés comme activés.
- Configuration SMTP par déploiement (variables `SMTP_*`, repli sur les credentials), expéditeur unique partagé par Devise et `ApplicationMailer`, options d'URL des liens (hôte, port, protocole) centralisées, avertissement au démarrage en production si SMTP n'est pas configuré. Le développement reste sur letter_opener_web sauf SMTP complet.
- La reconfirmation d'un changement d'adresse e-mail (déjà activée dans Devise) devient effective sans développement dédié.

Modèle de référence : le projet `saumon/lockswap` (spec 034), sans l'activation par un administrateur, sans les journaux `account_mail` et sans mailer dédié.

## Capabilities

### New Capabilities
- `mail-delivery`: configuration de l'envoi des e-mails de l'application (SMTP, expéditeur, adresse publique des liens) par déploiement.

### Modified Capabilities
- `manager-auth`: l'inscription n'ouvre plus de session mais exige l'activation par e-mail ; ajout de l'activation par lien, du renvoi de l'e-mail d'activation et du refus de connexion tant que le compte n'est pas activé.

## Impact

- Modèle `Manager` : `:confirmable`, migration (colonnes de confirmation, index, rattrapage des comptes existants).
- Contrôleurs/routes : `Managers::ConfirmationsController`, `devise_for :managers` avec contrôleurs personnalisés.
- Vues et locales fr : e-mail de confirmation (HTML et texte), page de renvoi, messages de refus de connexion.
- Configuration : `config/application.rb`, `config/initializers/devise.rb`, `config/environments/*.rb`, `config/deploy.yml` (variables SMTP, secret pour le mot de passe), nouveau module de réglages mail.
- Tests : fixtures managers à confirmer, tests d'intégration d'inscription, nouveaux tests d'activation et de renvoi.
- Pas de nouvelle gem.
