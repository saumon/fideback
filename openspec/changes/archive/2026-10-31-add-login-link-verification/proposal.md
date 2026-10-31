# Proposal

## Why

Un mot de passe volé ou réutilisé suffit aujourd'hui pour ouvrir une session. L'Admin veut pouvoir exiger, pour tous les comptes, un second geste : cliquer sur un lien à usage unique reçu par e-mail. Le réglage est global et réversible, comme la fermeture des inscriptions.

## What Changes

- Un nouveau bloc **« Connexion par lien unique »** sur l'écran Danger zone affiche l'état (activée / désactivée) et permet de l'activer, après une confirmation rendue par le serveur, ou de la désactiver sans confirmation. Elle est désactivée par défaut.
- Quand elle est **activée**, une connexion par e-mail et mot de passe corrects n'ouvre **aucune session** : un lien à usage unique est envoyé par e-mail et la personne arrive sur un écran « Consultez votre boîte mail ». Le clic sur le lien ouvre la session et mène à la liste des campagnes.
- Le lien est valable **10 minutes**, ne sert qu'**une fois**, et un nouvel envoi invalide les précédents. Il n'est pas lié au navigateur : il peut être ouvert sur un autre appareil. Le renvoi est limité à un lien par minute et par compte.
- Un lien expiré, déjà utilisé, remplacé ou inconnu mène à une page explicative qui propose de recommencer la connexion.
- Tant que l'option est active, **« Se souvenir de moi »** est masqué sur le formulaire de connexion et le cookie correspondant est ignoré par le serveur, et la **réinitialisation du mot de passe ne connecte plus** : la personne revient à la connexion.
- Les **sessions déjà ouvertes** à l'activation restent valables. Désactiver l'option rétablit la connexion par mot de passe seul.
- Les comptes non activés, les mots de passe incorrects et les adresses inconnues se comportent comme avant : aucun lien n'est envoyé.

Hors périmètre : choix par utilisateur, application d'authentification ou codes à usage unique, codes de secours, déconnexion des sessions en cours à l'activation, lien lié au navigateur d'origine.

## Capabilities

### New Capabilities
- `login-link-verification`: second facteur par lien unique envoyé par e-mail, de la demande à l'ouverture de session, avec expiration, usage unique, renvoi et refus.

### Modified Capabilities
- `admin-danger-zone`: l'écran porte un second réglage, la connexion par lien unique, avec son état, son activation confirmée et sa désactivation.
- `manager-auth`: la connexion, « Se souvenir de moi » et la réinitialisation du mot de passe suivent le réglage de la connexion par lien.

## Impact

- Base : réglage `login_link_required` dans la table `settings` existante (aucune colonne à ajouter) ; nouvelle table pour les liens de connexion (jeton, compte, expiration, usage) avec migration.
- Code : modèle de lien de connexion, `Setting`, contrôleur de sessions Devise personnalisé (création sans session, ouverture par le lien, renvoi), réglages du modèle `Manager` qui coupent le cookie « se souvenir de moi » et la connexion après réinitialisation du mot de passe, e-mail de lien (HTML et texte), vues (attente, lien refusé, formulaire de connexion), `Admin::DangerZoneController` et sa vue, routes, styles.
- Tests : modèle, mailer, intégration (connexion avec option active et inactive, lien valide, expiré, réutilisé, remplacé, remember-me, reset), danger zone, test système du parcours.
- README : fonctionnement de la connexion par lien et risque de verrouillage si l'envoi d'e-mails tombe.
