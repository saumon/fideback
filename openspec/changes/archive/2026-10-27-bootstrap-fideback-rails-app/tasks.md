# Tasks

## 1. Socle de l'application

- [x] 1.1 Dans un shell de login (`bash -lc`), vérifier que Ruby 3.4.6 est disponible, installer la gem `rails` 8.1.4 et vérifier `rails _8.1.4_ -v`
- [x] 1.2 Générer l'application Rails 8.1.4 nommée `fideback` dans un répertoire temporaire, la fusionner à la racine sans écraser `.git` ni `openspec/`, et vérifier `bin/rails -v` affiche `Rails 8.1.4`
- [x] 1.3 Configurer la locale par défaut `fr`, le fuseau horaire et le mailer, et vérifier `bin/rails runner 'puts I18n.default_locale'` affiche `fr`
- [x] 1.4 Vérifier que `bin/rails test`, `bin/rubocop` et `bin/brakeman` passent sur le squelette vierge

## 2. Authentification des managers (`manager-auth`)

- [x] 2.1 Ajouter la gem `devise`, lancer l'installeur et générer le modèle `Manager` (avec `name`) ; vérifier que la migration s'applique
- [x] 2.2 Générer et traduire en français les vues Devise, avec page d'accueil publique ; vérifier le rendu manuel des pages de connexion et d'inscription
- [x] 2.3 Protéger l'application par `authenticate_manager!` et rediriger vers la liste des campagnes après connexion ; ajouter les tests d'intégration couvrant inscription, connexion valide/invalide, déconnexion, réinitialisation (e-mail envoyé, e-mail inconnu) et accès anonyme, et vérifier qu'ils passent

## 3. Campagnes (`feedback-campaigns`)

- [x] 3.1 Créer les modèles `Campaign`, `Subject`, `Respondent`, `Question` avec contraintes d'unicité et validations (dont question avec note et/ou commentaire) ; ajouter les tests de modèle (doublon d'e-mail, états, question vide refusée) et vérifier qu'ils passent
- [x] 3.2 Implémenter le CRUD manager des campagnes scopé par `current_manager.campaigns`, avec formulaires imbriqués (managés, sondés, questions) et questions par défaut ; ajouter les tests d'intégration (création valide, isolation entre managers → 404) et vérifier qu'ils passent
- [x] 3.3 Implémenter `Campaign#launch!`, `#close!` et `accepting_answers?` avec verrouillage de l'édition après lancement ; tests de cycle de vie (lancement sans sondé/managé refusé, clôture, date limite) et vérification qu'ils passent
- [x] 3.4 Afficher le suivi par sondé et le taux de réponse sur la page de la campagne ; test d'intégration du rendu des statuts

## 4. Recueil des réponses (`feedback-submission`)

- [x] 4.1 Ajouter `Answer` et le jeton de `Respondent` ; ajouter les tests de modèle (note 1–5, unicité, cohérence avec le type de question) et vérifier qu'ils passent
- [x] 4.2 Créer `RespondentMailer#invitation`, déclenché au lancement via `deliver_later` ; tests de mailer et d'intégration (un e-mail par sondé avec lien et date limite)
- [x] 4.3 Implémenter l'accès public par jeton (404 si inconnu), le formulaire de réponse par managé hors soi-même, l'enregistrement partiel et la soumission finale avec validation de complétude ; tests d'intégration des scénarios de la spec
- [x] 4.4 Refuser toute écriture et afficher un message quand la campagne est clôturée ou la date limite dépassée ; tests d'intégration correspondants

## 5. Synthèse (`feedback-synthesis`)

- [x] 5.1 Implémenter l'objet de service de synthèse (soumissions finales seulement, moyennes, notes et commentaires attribués à leur sondé) ; tests unitaires vérifiant l'attribution et l'exclusion des réponses non soumises
- [x] 5.2 Ajouter les pages de synthèse par managé réservées au manager propriétaire, et la mention de transparence sur le formulaire sondé ; tests d'intégration (rendu nominatif, mention présente, 404 pour sondé ou autre manager)

## 6. Finalisation

- [x] 6.1 Ajouter un test système Capybara du parcours complet manager → lancement → réponse sondé → synthèse et vérifier qu'il passe
- [x] 6.2 Rédiger le `README.md` (prérequis, installation, lancement, tests, déploiement Kamal) et vérifier que les commandes documentées fonctionnent telles quelles
- [x] 6.3 Exécuter `bin/rails test`, `bin/rails test:system`, `bin/rubocop` et `bin/brakeman` et vérifier qu'ils sont tous verts
