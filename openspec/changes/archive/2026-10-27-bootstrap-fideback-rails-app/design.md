# Design

## Context

Dépôt vide (hors `openspec/`). Ruby 3.4.6 est installé via rvm (`/usr/local/rvm`) ; il n'est visible que dans un shell de login (`bash -lc '...'`), le `~/.bashrc` non interactif ne le chargeant pas. Voir `proposal.md` pour la motivation et les hypothèses, et `specs/` pour les exigences.

## Goals / Non-Goals

**Goals:**
- Monolithe Rails 8.1.4 « état de l'art » : conventions Rails, Hotwire, stack Solid, Minitest, sécurité par défaut.
- Isolation stricte des données par manager : les feedbacks nominatifs ne sont lisibles que de leur manager propriétaire.

**Non-Goals:**
- API JSON, SPA, SSO, multi-organisation, i18n multi-langue, export PDF, rappels automatiques.
- Comptes pour les sondés/managés.

## Decisions

**Génération.** `rails _8.1.4_ new fideback` à la racine existante (`--force` non nécessaire si on génère dans un répertoire temporaire puis on fusionne, `.git` et `openspec/` étant conservés). Stack par défaut : SQLite, Propshaft, importmap, Turbo/Stimulus, Solid Queue/Cache/Cable, Kamal, Brakeman, RuboCop omakase, Minitest + fixtures. *Alternatives* : PostgreSQL, RSpec, esbuild — rejetés pour rester sur les défauts maintenus par Rails.

**CSS.** CSS simple via Propshaft (pas de Tailwind) pour limiter les dépendances ; à revoir si l'UI grossit. *Alternative* : tailwindcss-rails.

**Authentification.** `devise` sur un modèle `Manager` avec modules `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `validatable`. Pas de `confirmable` pour la v1 (hypothèse : inscription ouverte). Vues Devise générées et traduites en `fr`. Les pages sondés n'utilisent pas Devise.

**Modèle de données.**
- `Manager` (devise, `name`)
- `Campaign` (`manager_id`, `name`, `deadline_on`, `status` enum `draft|running|closed`)
- `Subject` (managé : `campaign_id`, `name`, `email`) ; `Respondent` (sondé : `campaign_id`, `name`, `email`, `token`, `submitted_at`) ; unicité `(campaign_id, email)` pour chacun.
- `Question` (`campaign_id`, `position`, `prompt`, `rating` bool, `comment` bool ; au moins l'un des deux vrai)
- `Answer` (`respondent_id`, `subject_id`, `question_id`, `rating` int nullable, `body` text nullable) ; unicité `(respondent_id, subject_id, question_id)`.
`Respondent#token` via `generates_token_for`/`has_secure_token` (jeton long, non devinable) ; lookup par `find_by!(token:)`.

**Autorisation.** Pas de gem : toutes les requêtes manager passent par `current_manager.campaigns`, ce qui produit un 404 pour les campagnes d'autrui. Les pages sondés sont scopées par jeton, sans accès à la synthèse.

**Cycle de vie.** `Campaign#launch!` (transaction : validations de présence, statut `running`, envoi des invitations en `deliver_later` via Solid Queue) et `#close!`. Un concern/predicate `accepting_answers?` (statut `running` et date limite non dépassée) est la source de vérité unique pour la fermeture des réponses.

**Synthèse nominative.** Un objet de service construit, par managé et par question, les moyennes et la liste (sondé, note, commentaire) des soumissions finales (`submitted_at` non nul). Aucune anonymisation ni seuil minimal : le formulaire sondé affiche clairement que les réponses sont nominatives (transparence). *Alternative* : anonymat avec seuil — écartée par décision du produit.

**E-mails.** Action Mailer + Solid Queue ; SMTP configuré par credentials en production, `letter_opener` ou preview en développement.

**Tests.** Minitest : modèles (validations, cycle de vie, unicité), contrôleurs/intégration (auth, isolation, accès par jeton, fermeture), mailer, tests système (Capybara) pour le parcours manager → sondé → synthèse.

## Risks / Trade-offs

- [Feedbacks nominatifs sensibles (données personnelles)] → accès strictement limité au manager propriétaire (404 sinon), mention explicite aux sondés, HTTPS en production, filtrage des paramètres sensibles dans les logs.
- [Lien de sondé fuité ou transféré] → jeton long, HTTPS, fermeture à la clôture/date limite ; rotation du jeton non prévue en v1.
- [Inscription ouverte à n'importe qui] → acceptable en v1 ; envisager une invitation ou une liste blanche de domaines ensuite.
- [SQLite en production] → suffisant pour un monolithe mono-serveur avec volumes de volume faibles ; volume Kamal persistant et sauvegardes à prévoir.
- [Ruby seulement dans un shell de login] → exécuter les commandes via `bash -lc` ; version figée dans `.ruby-version`.
