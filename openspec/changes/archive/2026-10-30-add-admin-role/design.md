# Design

## Context

Voir proposal.md pour la motivation. `Manager` (Devise) n'a aucune colonne de rôle, `ApplicationController` n'impose que `authenticate_manager!`, et les routes n'ont aucun espace `admin`. La base est SQLite. La migration `AddConfirmableToManagers` a déjà posé le précédent : une migration `up`/`down` qui rattrape les comptes existants en SQL.

## Goals / Non-Goals

**Goals:**
- Un rôle simple, extensible, et une garde d'accès réutilisable par les futures pages d'administration.
- Une attribution du premier Admin sans course entre inscriptions simultanées.

**Non-Goals:**
- Aucune action d'administration, aucune gestion des rôles (promotion, rétrogradation), aucune garde contre l'auto-suppression de l'Admin.
- Aucun remplacement automatique d'un Admin supprimé : personne ne redevient Admin.

## Decisions

**Rôle en enum sur `managers.role` (chaîne, `NOT NULL`, défaut `manager`).** Alternative écartée : un booléen `admin`, qui ne se prête pas à un troisième rôle. L'enum Rails est déclaré avec des valeurs en chaîne (`manager`, `admin`), ce qui donne `admin?` et un `scope :admin`.

**Attribution dans un `before_create` du modèle, pas dans le contrôleur d'inscription.** La règle (« table vide ») vaut pour toute création, y compris par console ou fixture, et le callback s'exécute dans la transaction de l'insertion. Il pose `admin` si `Manager.none?` et le défaut sinon. Alternative écartée : l'attribuer dans `Managers::RegistrationsController`, qui n'est pas le seul chemin de création et sépare le test de l'insertion.

**Concurrence.** Le test « table vide » et l'insertion partagent la même transaction ; SQLite n'admet qu'un écrivain à la fois et Rails ouvre ses transactions SQLite en mode `IMMEDIATE`, donc le second inscrit voit le premier. À vérifier par un test (deux créations enchaînées) ; si le mode ne le garantit pas dans cette version, verrouiller explicitement avant le test. Alternative écartée : un index unique partiel sur `role = 'admin'`, qui empêcherait aussi d'ajouter plus tard un second Admin.

**Reprise des comptes existants en SQL dans la migration.** La colonne est ajoutée avec son défaut, puis `UPDATE managers SET role = 'admin' WHERE id = (SELECT id FROM managers ORDER BY created_at, id LIMIT 1)`. Sans manager, la sous-requête est vide et rien n'est modifié. `down` retire la colonne. Le tri sur `created_at` puis `id` départage deux comptes créés à la même seconde.

**Garde dans un contrôleur de base `Admin::BaseController`.** Il hérite d'`ApplicationController` (l'authentification reste donc celle de Devise : visiteur anonyme renvoyé vers la connexion) et ajoute un `before_action` qui lève `ActionController::RoutingError` / rend 404 si `!current_manager.admin?`. 404 plutôt que 403 ou redirection avec message : l'existence de la page n'est pas révélée. `Admin::DashboardController#show` en est le premier enfant, monté sur `namespace :admin` avec `root "dashboard#show"`, soit `/admin`.

**Lien de menu dans le layout**, conditionné par `current_manager.admin?`, placé après « Mon équipe ». La vue d'accueil reste sobre et reprend les classes de page existantes ; le style de l'écran respecte la direction visuelle du projet (colorée, animée, pas sobre).

## Risks / Trade-offs

- [Premier compte jamais activé ou adresse erronée → Admin inaccessible] → Accepté : choix explicite d'attribuer le rôle à l'inscription. Sans action d'administration, l'impact est nul pour l'instant.
- [Admin supprimé → plus aucun Admin] → Accepté : empêche de prendre le rôle en s'inscrivant juste après. À reprendre quand l'écran aura des actions (garde contre l'auto-suppression, ou rôle repris à la main en console).
- [Promotion du plus ancien en production] → La personne promue n'est pas forcément celle qui doit l'être ; en cas de doute, la corriger à la main après le déploiement.

## Migration Plan

1. Déployer : la migration ajoute `role` et promeut le manager le plus ancien.
2. Vérifier en console qu'il y a exactement un Admin.
3. Retour arrière : `down` retire la colonne ; le code qui la lit doit alors être retiré aussi.
