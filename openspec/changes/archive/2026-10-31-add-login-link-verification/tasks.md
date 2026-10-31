## 1. Réglage et données

- [x] 1.1 Ajouter `Setting.login_link_required?` (faux par défaut) et `Setting.login_link_required=`
- [x] 1.2 Créer la migration de la table `login_links` (`manager_id` en cascade, `token` unique, `expires_at`, `used_at`, horodatages), mettre à jour `db/schema.rb`
- [x] 1.3 Créer le modèle `LoginLink` : jeton, `VALIDITY`, `COOLDOWN`, `issue_for` (remplacement des liens précédents, délai d'une minute, e-mail mis en file), `usable?`, `consume!` atomique

## 2. E-mail

- [x] 2.1 Créer `LoginLinkMailer#link` et ses vues HTML et texte (salutation, bouton « Me connecter », 10 minutes, usage unique, consigne d'ignorer le message)

## 3. Connexion

- [x] 3.1 Vérifier que `warden.authenticate` avec `store: false` conserve les échecs de Devise (mot de passe, compte non activé) ; sinon, valider à la main avec les mêmes messages
- [x] 3.2 Créer `Managers::SessionsController` (option active : authentification sans session, identifiant mis en session, lien émis, redirection 303 vers l'écran d'attente), routes `sign_in/link` (écran, renvoi) et `sign_in/link/:token` (ouverture)
- [x] 3.3 Créer l'écran d'attente (adresse, validité, renvoi désactivé pendant le délai, changer d'adresse) et la page de lien refusé (encadré safran, statut 404)
- [x] 3.4 Ouvrir la session par le lien (consommation, `sign_in`, message, redirection) en renvoyant un manager déjà connecté sans consommer le lien
- [x] 3.5 Masquer « Se souvenir de moi » sur le formulaire de connexion quand l'option est active
- [x] 3.6 Faire renvoyer `nil` à `Manager.serialize_from_cookie` et `false` à `Manager.sign_in_after_reset_password` quand l'option est active
- [x] 3.7 Ajouter les styles de l'écran d'attente et du lien refusé (jetons du thème, `prefers-reduced-motion` respecté)

## 4. Danger zone

- [x] 4.1 Ajouter le bloc « Connexion par lien unique » à la vue (état, rappel, activation confirmée, désactivation) et faire de `confirm` le nom du réglage concerné
- [x] 4.2 Étendre `Admin::DangerZoneController#update` à `login_link_required` (une seule valeur explicite acceptée, sinon 422) avec les notices d'activation et de désactivation

## 5. Tests

- [x] 5.1 Tests du modèle `LoginLink` et de `Setting` : émission, remplacement, délai d'une minute, expiration, usage unique
- [x] 5.2 Test du mailer : destinataire, sujet, salutation, lien dans les deux versions, 10 minutes
- [x] 5.3 Tests d'intégration de la connexion avec l'option active : aucune session avant le clic, e-mail envoyé, écran d'attente, mot de passe incorrect, compte non activé, lien valable, expiré, réutilisé, remplacé, depuis un autre navigateur, manager déjà connecté, renvoi et renvoi trop rapproché, changer d'adresse
- [x] 5.4 Tests d'intégration des contournements : case « Se souvenir de moi » absente, cookie ignoré, réinitialisation sans connexion automatique, sessions ouvertes conservées, option désactivée = connexion inchangée
- [x] 5.5 Mettre à jour les tests de la danger zone : activation confirmée et annulée, sans JavaScript, désactivation, accès réservé, valeur invalide, réglages indépendants, `confirm` par nom de réglage
- [x] 5.6 Test système du parcours : l'Admin active l'option, une autre session saisit son mot de passe, ouvre le lien reçu et arrive sur ses campagnes

## 6. Documentation et vérification

- [x] 6.1 Décrire la connexion par lien dans le README (fonctionnement, ce qui est coupé, limite face à la boîte mail, retour arrière par la console)
- [x] 6.2 Contrôler dans un navigateur la danger zone, l'écran d'attente, l'e-mail et le lien refusé sur bureau et sur mobile, avec et sans mouvement réduit
- [x] 6.3 Lancer `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, puis `bin/ci` avant fusion
- [x] 6.4 À l'archivage, réécrire le Purpose de la spec principale `admin-danger-zone`, qui ne parle que des inscriptions
