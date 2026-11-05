# Design

## Context

Le dépôt a un skill de fin de session, `/saumon-finish`, qui fixe les conventions : `AskUserQuestion` pour chaque question, confirmation avant chaque écriture, refus de continuer si l'une des quatre vérifications échoue, réponses en français, aucun message d'attribution. Ruby n'est pas dans le `PATH` (`/usr/local/rvm/rubies/ruby-3.4.6/bin`). `.github/dependabot.yml` couvre `bundler` et `github-actions`. Les branches Dependabot sont poussées par GitHub sur `origin` ; la branche d'intégration est `dev`, `master` n'est pas concernée.

## Goals / Non-Goals

**Goals:**
- Un parcours unique, du choix de la branche au merge dans `dev`, avec arrêt sûr à chaque échec.
- Aucune écriture distante avant que les vérifications soient vertes sur la branche rebasée.
- Cohérence de forme avec `/saumon-finish` (frontmatter, ton, structure par étapes numérotées).

**Non-Goals:**
- Aucun script ni automatisation hors du fichier `SKILL.md`.
- Pas de traitement par lot, pas de validation spécifique aux mises à jour de GitHub Actions (non couvertes par `bin/ci`, signalées seulement).

## Decisions

1. **Skill en Markdown pur, `disable-model-invocation: true`.** Comme `/saumon-finish`, pour qu'un push forcé ne soit jamais déclenché implicitement. Alternative : script shell ; écartée, les confirmations interactives et la lecture des échecs sont le rôle de l'agent.
2. **Liste triée par `git for-each-ref --sort=committerdate refs/remotes/origin/dependabot`** après `git fetch --prune`. Affichage : date, nom sans le préfixe `origin/`. Choix par `AskUserQuestion` (4 options maximum : au-delà, proposer les plus anciennes et « Autre »). Aucune branche : le skill le dit et s'arrête.
3. **Garde-fous de départ.** Branche courante `dev`, arbre propre, `dev` à jour (`git pull --ff-only`). Sinon arrêt avec explication : le skill ne stashe pas et ne change pas de branche à la place de l'utilisateur.
4. **Rebase sur une branche locale temporaire.** `git switch -c <branche> origin/<branche>` puis `git rebase origin/dev`. Le travail se fait sur la copie locale ; `dev` reste intact tant que rien n'est mergé. Conflit : `git rebase --abort`, retour sur `dev`, suppression de la branche locale, explication, aucune écriture distante. Si la branche est déjà à jour (rebase sans effet, `origin/dev` ancêtre), l'étape de push forcé est sautée.
5. **Vérifications identiques à `/saumon-finish`** : `bin/rails test`, `bin/rubocop`, `bin/rails test:system`, `bin/ci`, avec `PATH` ajusté pour Ruby, sans interruption des tests système. Les quatre doivent passer ; sinon arrêt, retour sur `dev` et suppression de la branche locale, sans commit ni push.
6. **Confirmation 1 : `git push --force-with-lease origin <branche>`.** Le lease protège d'un push concurrent de Dependabot. Si le push est rejeté, le skill l'explique (Dependabot a réécrit la branche) et propose de recommencer depuis un `fetch`, sans retenter de force. Jamais `--force` nu.
7. **Confirmation 2 : merge puis push.** `git switch dev`, `git merge --no-ff <branche>` avec le message par défaut de git, puis `git push origin dev`. Le commit de la branche rebasée étant contenu dans `dev`, GitHub marque la PR comme fusionnée. Un échec du push de `dev` est affiché sans autre tentative ; le merge local reste en place, à signaler.
8. **Confirmation 3 : suppression de la branche distante** (`git push origin --delete <branche>`), proposée après le merge ; la branche locale est supprimée dans tous les cas une fois mergée.
9. **Mises à jour `github_actions`** : `bin/ci` ne les exerce pas. La liste les repère par leur préfixe et le skill l'indique avant le choix, sans changer le parcours.

## Risks / Trade-offs

- [Push forcé sur une branche partagée] → `--force-with-lease`, confirmation explicite, périmètre limité aux branches `dependabot/*`.
- [Dependabot réécrit la branche pendant les vérifications] → le lease échoue ; message clair et reprise depuis `fetch`.
- [Tests système longs] → délai de commande relevé, comme dans `/saumon-finish`.
- [Un échec laisse des branches locales] → nettoyage (retour sur `dev`, suppression de la branche locale) à chaque sortie anticipée.
- [Doublons entre `bin/ci` et les tests déjà lancés] → accepté pour rester identique à `/saumon-finish`.
