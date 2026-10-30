## 1. Réglage

- [x] 1.1 Créer la migration de la table `settings` (`key` unique non nulle, `value`) et mettre à jour `db/schema.rb`
- [x] 1.2 Créer le modèle `Setting` avec `registrations_open?` (ouvert si la clé est absente) et `registrations_open=`

## 2. Garde de l'inscription

- [x] 2.1 Dans `Managers::RegistrationsController`, ajouter `require_open_registrations` sur `new` et `create` (laisse passer si les inscriptions sont ouvertes ou si aucun manager n'existe), qui redirige vers l'accueil avec le flash `warning`, en 303
- [x] 2.2 Vérifier que les liens « Créer un compte » (accueil, en-tête, tiroir mobile, page de connexion) restent affichés et que l'activation, le renvoi d'e-mail, la connexion et la réinitialisation ne sont pas touchés

## 3. Toast d'avertissement

- [x] 3.1 Dans `_toasts.html.erb`, retenir `warning` du flash, avec la classe `flash-warning` et sans `role="alert"`
- [x] 3.2 Dans `toasts_controller.js`, allonger de 2 s la durée d'un avertissement par rapport à une notice de même texte, dans une borne maximale élargie en conséquence
- [x] 3.3 Dans `application.css`, ajouter `.toast.flash-warning` en safran et vérifier le minuteur, la fermeture, l'empilement et le mouvement réduit

## 4. Écran Danger zone

- [x] 4.1 Ajouter la route `admin/danger-zone` (`show`, `update`) et `Admin::DangerZoneController` (hérite d'`Admin::BaseController`) : `show` gère `confirm=1`, `update` enregistre le réglage, redirige avec une notice
- [x] 4.2 Créer la vue : titre « Danger zone », lien de retour vers l'administration, carte de zone de danger avec libellé, pastille d'état, rappel de l'exception du site vide, bouton « Désactiver » (lien de confirmation) ou « Réactiver », carte de confirmation avec « Annuler »
- [x] 4.3 Ajouter le style de la zone de danger, de la pastille d'état et de la carte de confirmation (couleurs du thème, `prefers-reduced-motion` respecté)
- [x] 4.4 Ajouter le bouton « Danger zone » (style `.btn-danger`) sur `app/views/admin/dashboard/show.html.erb`

## 5. Tests

- [x] 5.1 Test de modèle `Setting` : ouvert par défaut, fermeture, réouverture
- [x] 5.2 Tests d'intégration de l'écran : accès Admin, 404 pour un manager (affichage et `PATCH`), redirection d'un visiteur, état affiché, confirmation, annulation, désactivation, réactivation, notices
- [x] 5.3 Tests d'intégration de l'inscription fermée : refus du `GET` et du `POST` avec avertissement et redirection, aucun compte ni e-mail créés, exception sans aucun manager, liens toujours affichés, comptes existants non affectés
- [x] 5.4 Test d'intégration du balisage du toast d'avertissement, et test système du clic sur « Créer un compte » (toast safran, retour à l'accueil)
- [x] 5.5 Mettre à jour `test/integration/admin_area_test.rb` pour le bouton « Danger zone »

## 6. Documentation et vérification

- [x] 6.1 Décrire le réglage et l'écran « Danger zone » dans le README
- [x] 6.2 Contrôler dans un navigateur l'écran, la confirmation et le toast sur bureau et sur mobile, avec et sans mouvement réduit
- [x] 6.3 Lancer `bin/rails test`, `bin/rails test:system`, `bin/rubocop`, puis `bin/ci` avant fusion
