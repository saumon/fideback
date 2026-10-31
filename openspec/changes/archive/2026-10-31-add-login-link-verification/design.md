# Design

## Context

La connexion est celle de Devise, sans contrôleur surchargé : `Manager` est `database_authenticatable`, `confirmable`, `recoverable`, `rememberable`. `ApplicationController` impose `authenticate_manager!` et envoie vers `campaigns_path` après connexion. Le réglage de l'inscription vit dans `Setting` (clé/valeur, valeur absente = défaut) et dans `Admin::DangerZoneController`, dont la confirmation est rendue par le serveur (`?confirm=1`). Les e-mails passent par `deliver_later` (Solid Queue) dans l'habillage commun, et les invitations ont déjà un jeton `has_secure_token` à usage unique. Voir proposal.md pour la motivation et les specs pour le comportement attendu.

Deux sorties de Devise ouvrent une session sans passer par le mot de passe : le cookie `rememberable` et la réinitialisation du mot de passe (`sign_in_after_reset_password`, vrai par défaut).

## Goals / Non-Goals

**Goals:**
- Aucune session n'existe avant le clic sur le lien.
- Garder les messages et les cas d'échec de la connexion Devise (identifiants invalides, compte non activé).
- Fermer les deux contournements ci-dessus sans toucher à la configuration globale de Devise.

**Non-Goals:**
- Une gem de second facteur ou des codes à usage unique.
- Lier le lien au navigateur d'origine.
- Couper les sessions ouvertes à l'activation.

## Decisions

- **Réglage `login_link_required` dans `Setting`.** `Setting.login_link_required?` vaut `false` tant que la ligne est absente ; `Setting.login_link_required=` suit le modèle de `registrations_open=`. Aucune migration pour le réglage.
- **Table `login_links`.** `manager_id` (clé étrangère, suppression en cascade), `token` (36 caractères, `has_secure_token`, unique), `expires_at`, `used_at`, horodatages. Le jeton est stocké tel quel, comme celui des invitations : l'e-mail est mis en file avec le lien en argument, donc le jeton traverse de toute façon la base de la file ; hacher la table n'apporterait rien. Il est protégé par sa brièveté (10 minutes), son usage unique et sa longueur. Alternative écartée : un jeton signé sans table (`signed_id`) : pas d'usage unique ni d'invalidation par renvoi sans état en base.
- **Modèle `LoginLink`.** `LoginLink.issue_for(manager)` supprime les liens précédents du compte, en crée un (`VALIDITY = 10.minutes`) et met l'e-mail en file ; il ne fait rien si le dernier envoi date de moins d'une minute (`COOLDOWN = 1.minute`) et renvoie alors `nil`. `#usable?` : ni utilisé ni expiré. `#consume!` : marque `used_at` de façon atomique (`UPDATE … WHERE used_at IS NULL`) et renvoie faux si un autre clic a gagné, pour qu'un double clic simultané n'ouvre pas deux fois la session. Les liens expirés du compte sont supprimés à chaque émission : pas de tâche de purge.
- **Connexion sans session.** `Managers::SessionsController < Devise::SessionsController`. Quand l'option est active, `create` authentifie avec la stratégie de Devise sans stocker la session (`warden.authenticate(auth_options.merge(store: false))`), ce qui conserve les échecs existants (mot de passe incorrect, compte non activé) ; en cas de succès, il enregistre l'identifiant du compte dans la session Rails (`login_link_manager_id`), émet le lien et redirige en 303 vers l'écran d'attente. Option inactive : comportement de Devise inchangé. Le comportement de `store: false` avec les hooks Devise (activable, rememberable) est à vérifier en premier lors de l'implémentation ; le repli est de valider à la main `valid_password?` et `active_for_authentication?` en rendant les mêmes messages. Alternative écartée : ouvrir la session puis la marquer « en attente » avec un filtre global : un oubli de filtre suffit à contourner la protection.
- **Écran d'attente et renvoi.** `GET /managers/sign_in/link` (écran, refusé sans `login_link_manager_id` en session : redirection vers la connexion) et `POST` pour renvoyer, qui rappelle `issue_for`. « Changer d'adresse » efface l'identifiant en session. Pendant le délai, le bouton est rendu désactivé avec les secondes restantes calculées au rendu, et un petit contrôleur Stimulus (`countdown`) les décompte puis réactive le bouton, sur une échéance absolue pour rester juste après un onglet en arrière-plan ; sans JavaScript, la page reste correcte, le texte ne bouge simplement pas. Le serveur refuse de toute façon une demande trop tôt (message d'avertissement). L'écran répond de la même façon pour tout compte validé par mot de passe, donc ne révèle rien à un tiers.
- **Ouverture par le lien.** `GET /managers/sign_in/link/:token` : un lien utilisable est consommé, `sign_in(manager)` ouvre la session et la personne arrive sur `after_sign_in_path_for`, avec le message « Vous êtes connecté. ». Un lien inutilisable, ou celui d'un compte devenu inactif, rend la page de lien refusé avec le statut 404 (même encadré safran que l'invitation invalide), sans distinguer les cas. Un manager déjà connecté est renvoyé avec l'alerte habituelle de Devise sans consommer le lien, via la garde `require_no_authentication`. L'identifiant mémorisé en session est effacé à la connexion.
- **« Se souvenir de moi ».** La vue de connexion n'affiche la case que si l'option est inactive. Côté serveur, `Manager.serialize_from_cookie` renvoie `nil` quand l'option est active : le cookie déjà émis ne connecte plus, sans toucher aux données ni aux sessions classiques. Devise supprime le cookie dès qu'il est refusé : la personne devra se reconnecter, même après une désactivation de l'option ; accepté.
- **Réinitialisation du mot de passe.** `Manager.sign_in_after_reset_password` renvoie `!Setting.login_link_required?`. Devise ne connecte alors pas la personne et la redirige vers la connexion avec son message « mot de passe changé, compte non connecté » ; aucun contrôleur de mots de passe à surcharger.
- **Danger zone.** Un second bloc dans la vue, mêmes composants que les inscriptions. `update` accepte un seul de ses deux paramètres (`registrations_open` ou `login_link_required`, valeurs `true` ou `false` seulement, sinon 422). La confirmation d'activation est rendue par le serveur : `confirm` prend le nom du réglage concerné (`registrations` ou `login_link`) au lieu de `1`, et les tests existants suivent. Activer demande la confirmation, désactiver non (l'inverse des inscriptions, mais toujours la voie restrictive qui confirme).
- **E-mail.** `LoginLinkMailer#link(login_link)` dans l'habillage commun, vues HTML et texte, bouton « Me connecter », URL en clair dans la version texte, 10 minutes et usage unique rappelés, phrase « ignorez ce message ». L'hôte est celui des autres e-mails.
- **Style.** Maquette validée : carte d'attente avec enveloppe animée et pastilles « Valable 10 minutes », « Un seul usage » ; encadré safran du lien refusé ; bloc de danger zone en bordure pointillée, comme les inscriptions. Mouvement réduit respecté par la règle globale.

## Risks / Trade-offs

- [Panne d'envoi d'e-mails : plus personne ne peut se connecter, l'Admin compris] → avertissement dans la confirmation d'activation ; retour arrière documenté dans le README (supprimer le réglage `login_link_required` depuis la console Rails).
- [Un analyseur de liens du service de messagerie (ex. protection de liens d'entreprise) ouvre le lien avant la personne et le consomme] → le lien reste à usage unique et le renvoi est possible ; si le cas se présente, ajouter un écran intermédiaire avec un bouton de confirmation, sans changer le reste du flux.
- [La boîte mail reçoit déjà le lien de réinitialisation du mot de passe] → ce second facteur protège d'un mot de passe volé ou réutilisé, pas d'une boîte mail compromise ; dit dans le README.
- [Le lien n'est pas lié au navigateur] → choix assumé pour permettre d'ouvrir le mail sur un téléphone ; durée de 10 minutes et usage unique limitent l'exposition.
- [Activation avec des sessions ouvertes] → elles restent valables, l'Admin ne se coupe pas de son écran.
- [`store: false` de Warden et les hooks Devise] → à vérifier en premier ; repli prévu ci-dessus.

## Migration Plan

Déployer le code et jouer la migration `create_login_links` ; l'option est désactivée par défaut, rien ne change tant que l'Admin ne l'active pas. Retour arrière : la désactiver dans la danger zone, ou supprimer la ligne `login_link_required` de `settings` si l'accès à l'application est perdu.
