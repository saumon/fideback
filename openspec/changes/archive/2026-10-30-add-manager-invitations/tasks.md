## 1. Données et modèle

- [x] 1.1 Créer la migration de la table `invitations` (`name`, `email`, `token` unique, `expires_at`, `accepted_at`, `invited_by_id` en `ON DELETE SET NULL`, horodatages) avec un index unique partiel sur `email` là où `accepted_at IS NULL`, et mettre à jour `db/schema.rb`
- [x] 1.2 Créer le modèle `Invitation` : jeton, normalisation de l'e-mail, validations (nom, e-mail, adresse sans compte), états `pending?` `expired?` `accepted?`, portée `unaccepted`, `VALIDITY`
- [x] 1.3 Ajouter `Invitation.invite!` et `#renew!` (jeton régénéré, expiration repoussée, e-mail mis en file dans une transaction) et `#accept` (création du manager activé via `skip_confirmation!`, invitation marquée acceptée, dans une transaction)
- [x] 1.4 Ajouter les noms d'attributs et les messages de validation de `Invitation` dans `config/locales`

## 2. E-mail

- [x] 2.1 Créer `InvitationMailer#invitation` et ses vues HTML et texte (salutation par le nom, invitant, bouton « Accepter l'invitation », date limite, lien personnel) dans l'habillage commun

## 3. Côté administration

- [x] 3.1 Ajouter les routes `admin/invitations` (`new`, `create`, `destroy`, `resend`) et `Admin::InvitationsController` avec notices, redirections vers `/admin/users` et formulaire réaffiché en 422 si invalide
- [x] 3.2 Créer la vue du formulaire d'invitation (nom, e-mail, lien de retour, rappel de la validité)
- [x] 3.3 Dans `Admin::UsersController#index` et sa vue : bouton « Inviter un manager » dans l'en-tête, bloc « Invitations en attente » (nom, e-mail, date, état, « Renvoyer », « Annuler » avec confirmation) ou message d'absence
- [x] 3.4 Ajouter les styles du bloc de suivi et de la pastille « Expirée » (couleurs du thème, `prefers-reduced-motion` respecté)

## 4. Côté invité

- [x] 4.1 Ajouter les routes `invitations/:token` et `InvitationAcceptancesController` (`show`, `update`) sans authentification requise, avec renvoi des managers connectés, redirection en 303 vers la connexion et notice après acceptation
- [x] 4.2 Créer la vue d'acceptation (nom pré-rempli, e-mail verrouillé, mot de passe et confirmation, erreurs) et la vue « invitation invalide » commune à tous les cas
- [x] 4.3 Vérifier que l'acceptation fonctionne inscriptions fermées et que le contrôleur d'inscription Devise n'est pas touché

## 5. Tests

- [x] 5.1 Tests du modèle : états, validations (adresse inscrite, casse), `invite!` (création, remplacement), `renew!`, `accept` (compte activé, rôle, invitation consommée, adresse devenue inscrite)
- [x] 5.2 Test du mailer : destinataire, sujet, salutation, invitant, lien dans les deux versions, date limite, expéditeur commun
- [x] 5.3 Tests d'intégration de l'administration : accès Admin, 404 manager, redirection visiteur, création, erreurs, adresse déjà inscrite, remplacement, renvoi, annulation, bloc de suivi, bouton
- [x] 5.4 Tests d'intégration de l'acceptation : succès (compte activé, aucun e-mail d'activation, pas de session, redirection), inscriptions fermées, mot de passe invalide, nom corrigé, lien expiré, annulé, remplacé, utilisé, adresse devenue inscrite, manager connecté
- [x] 5.5 Test système du parcours : l'Admin invite, ouvre le lien reçu, crée le compte puis se connecte avec
- [x] 5.6 Mettre à jour les tests de l'écran des utilisateurs pour les nouvelles actions

## 6. Documentation et vérification

- [x] 6.1 Décrire les invitations dans le README
- [x] 6.2 Contrôler dans un navigateur le formulaire, le suivi et la page d'acceptation sur bureau et sur mobile, avec et sans mouvement réduit
- [x] 6.3 Lancer `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, puis `bin/ci` avant fusion
- [x] 6.4 À l'archivage, réécrire le Purpose de la spec principale `admin-users`, qui parle encore de « lecture seule »
