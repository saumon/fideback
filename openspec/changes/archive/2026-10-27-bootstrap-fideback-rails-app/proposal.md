# Proposal

## Why

Les managers préparent leurs entretiens individuels de fin d'année avec des retours épars et souvent incomplets. Fideback leur permet de recueillir, de façon structurée, les feedbacks de plusieurs sondés sur chacun de leurs managés, puis de les consolider pour préparer l'entretien. Le dépôt est vide : cette change crée l'application et son premier périmètre fonctionnel.

## What Changes

- Création d'une application monolithique **Ruby on Rails 8.1.4** nommée `fideback`, avec la stack par défaut de Rails 8.1 (Hotwire, Propshaft, Solid Queue/Cache/Cable, Minitest).
- Authentification des managers avec la gem **devise** (inscription, connexion, déconnexion, réinitialisation du mot de passe).
- Un manager crée une **campagne de feedback** : nom, période, liste finie de **managés** (sujets du feedback), liste finie de **sondés** (personnes interrogées) et questionnaire.
- Lancement de la campagne : chaque sondé reçoit par e-mail un **lien personnel à jeton** (sans compte) pour répondre, pour chaque managé, aux questions de la campagne.
- Suivi de l'avancement et clôture de la campagne par le manager.
- **Synthèse** par managé, consultable par le manager, pour préparer l'entretien individuel ; les réponses y sont **nominatives** (le manager voit qui a dit quoi).

### Hypothèses (validées par l'utilisateur)

- Seuls les managers ont un compte ; les sondés et managés sont de simples contacts (nom + e-mail) rattachés à une campagne, non authentifiés par devise.
- Un sondé peut aussi être managé dans la même campagne, mais ne répond pas sur lui-même.
- Le questionnaire d'une campagne est une liste ordonnée de questions, chacune pouvant comporter un commentaire texte libre et/ou une note de 1 à 5 ; un jeu de questions par défaut est proposé à la création.
- Les réponses ne sont **pas anonymisées** : le manager voit qui a répondu ou non, et qui a dit quoi.
- Application en français uniquement (i18n Rails, locale `fr`), base SQLite (défaut Rails 8), pas de multi-organisation.

## Capabilities

### New Capabilities
- `manager-auth`: inscription, connexion, déconnexion et réinitialisation de mot de passe des managers.
- `feedback-campaigns`: création, édition, lancement, suivi et clôture d'une campagne avec ses managés, sondés et questions, isolée par manager.
- `feedback-submission`: envoi des invitations et recueil des réponses des sondés via lien personnel à jeton.
- `feedback-synthesis`: consolidation nominative des réponses par managé pour le manager.

### Modified Capabilities
<!-- Aucune : le dépôt ne contient pas encore de spécification. -->

## Impact

- Nouveau code : application Rails complète à la racine du dépôt (`app/`, `config/`, `db/`, `test/`, `Gemfile`, etc.).
- Dépendances : Ruby (version supportée par Rails 8.1.4), Rails 8.1.4, devise, plus les gems par défaut de Rails 8.1.
- Environnement : Ruby 3.4.6 est installé via rvm (disponible dans un shell de login, ex. `bash -lc`).
- Données personnelles (noms, e-mails, feedbacks) : exigence d'isolation entre managers (les feedbacks nominatifs ne sont visibles que du manager propriétaire).
- Hors périmètre : SSO, multi-organisation, export PDF, rappels automatiques, API JSON, internationalisation multi-langue.
