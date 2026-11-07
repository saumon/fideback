# Tasks

## 1. Suppression côté serveur

- [x] 1.1 Ajouter `destroy` à `resources :users` de l'espace `admin` et l'action `Admin::UsersController#destroy` (cible via `Manager.find`, refus avec alerte si c'est `current_manager`, sinon `destroy` puis redirection 303 avec notice) ; vérifier avec des tests d'intégration dans `test/integration/admin_users_test.rb` : suppression par l'Admin, auto-suppression refusée sans rien supprimer, 404 pour un non-Admin, redirection de connexion pour un anonyme, 404 pour un manager déjà supprimé.
- [x] 1.2 Vérifier les effets de la cascade par des tests de modèle ou d'intégration : campagnes (y compris en cours), sondés et réponses effacés, contacts et liens de connexion effacés, invitations envoyées conservées avec `invited_by` vide, aucun e-mail envoyé (`assert_no_enqueued_emails`), adresse de nouveau invitable ; un manager non confirmé est supprimé comme les autres.
- [x] 1.3 Vérifier l'invalidation de la session par un test d'intégration : un manager connecté est supprimé par l'Admin, sa requête suivante vers une page réservée redirige vers la connexion.

## 2. Écran « Utilisateurs »

- [x] 2.1 Ajouter un helper de détail de confirmation (même style que `delete_campaign_detail`, accord singulier/pluriel, cas « aucune campagne ») et vérifier avec un test de helper dans `test/helpers`.
- [x] 2.2 Charger les nombres de campagnes par manager sans N+1 dans `Admin::UsersController#index`, et ajouter dans `app/views/admin/users/index.html.erb` une colonne d'action avec un bouton « Supprimer » (`button_to`, `method: :delete`, `turbo_confirm` ton danger, icône `trash`, détail chiffré) sur chaque ligne sauf celle de `current_manager` ; vérifier par des tests de vue dans `test/integration/admin_users_test.rb` (bouton présent sur les autres lignes, absent sur la sienne, détail chiffré dans la confirmation).
- [x] 2.3 Mettre à jour le test existant « the screen offers no action on the listed accounts, only on invitations » pour qu'il reflète la spec modifiée (aucun changement de rôle ni modification ; suppression des autres managers) et vérifier que la suite `test/integration/admin_users_test.rb` passe.
- [x] 2.4 Ajouter un test système dans `test/system` : l'Admin ouvre la confirmation, l'annule (le manager reste), puis la confirme (le manager disparaît, notice affichée), et vérifier qu'il passe.

## 3. Spec principale et contrôle final

- [x] 3.1 Mettre à jour le Purpose de `openspec/specs/admin-users/spec.md` (il dit encore « sans jamais modifier les comptes existants ») pour mentionner la suppression d'un manager, et vérifier avec `openspec validate admin-delete-user --strict`.
- [x] 3.2 Lancer la suite de tests complète (`bin/rails test` et `bin/rails test:system`, avec Ruby de `/usr/local/rvm/rubies/ruby-3.4.6/bin`) ainsi que les vérifications avant fusion de `project-conventions`, et confirmer que tout passe.

## Workflow follow-up

- Archiver le change une fois la revue passée (`/opsx:archive`).
